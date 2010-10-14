require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe SData::Application, "#sdata_scope" do
  context "given a resource and trying to access a linked model" do
    context "being configured with user scoping" do
      before :all do
        BaseModel = Class.new(ActiveRecord::Base)

        Object.__send__ :remove_const, :SomeResource if defined?(SomeResource)

        class SomeResource < SData::Resource::Base
          self.baze_class = BaseModel

          define_payload_map :born_at => { :baze_field => :born_at }

          has_sdata_options :link => :simply_guid,
            :feed =>
              { :author => 'Billing Boss',
              :path => '/trading_accounts',
              :title => 'Billing Boss | Trading Accounts',
              :default_items_per_page => 10,
              :maximum_items_per_page => 100 },
            :scoping => ["created_by_id = ?"]
        end
        SomeResource.stub! :all => []

        @app = SData::TestApplication.new
        @user = User.new.populate_defaults
        @app.stub! :current_user => @user
        @app.stub! :target_user => @user
      end

      context "with no other params" do
        before :each do
          @app.stub! :params => { :sdata_resource => 'SomeResource' }
        end

        it "should return all entity records created_by scope" do
          SomeResource.should_receive(:all).with :conditions => ['created_by_id = ?', "#{@user.id}"]
          @app.send :sdata_scope
        end
      end

      context "with condition and where clause" do
        before :each do
          @app.stub! :params => { 'where born_at gt 1900' => nil, :condition => '$linked', :sdata_resource => 'SomeResource' }
        end

        it "should return all entity records with created_by, predicate, and link scope" do
          BaseModel.should_receive(:find_with_deleted).with(:all, {:conditions => ['"born_at" > ? and created_by_id = ? and id IN (SELECT bb_model_id FROM sd_uuids WHERE bb_model_type = \'BaseModel\' and sd_class = \'SomeResource\')', '1900', @user.id.to_s]}).and_return([])
          @app.send :sdata_scope
        end
      end
    end
  end
end
