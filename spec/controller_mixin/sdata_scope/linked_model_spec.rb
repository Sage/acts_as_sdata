require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe SData::ControllerMixin, "#sdata_scope" do
  context "given linked model resource" do
    context "being configured without user scoping" do
      before :all do
        Object.__send__ :remove_const, :SomeResource if defined?(SomeResource)

        @application = SData::TestApplication.new

        BaseModel = Class.new(ActiveRecord::Base)

        class SomeResource < SData::Resource::Base
          self.baze_class = BaseModel

          define_payload_map :born_at => { :baze_field => :born_at }

          has_sdata_options :link => :simply_guid,
                            :feed =>
                           {:author => 'Billing Boss',
                            :path => '/trading_accounts',
                            :title => 'Billing Boss | Trading Accounts',
                            :default_items_per_page => 10,
                            :maximum_items_per_page => 100}
        end
      end

      before :each do
        @resource = SomeResource.new
        SomeResource.stub! :all => []
      end

      context "when params contain :condition key and where clause" do
        before :each do
          @application.stub! :params => { 'where born_at gt 1900' => nil, :condition => '$linked', :sdata_resource => 'SomeResource' }
        end

        it "should apply to SData::Predicate for conditions and append requirement for simply guid" do
          BaseModel.should_receive(:find_with_deleted).with(:all, {:conditions => ['"born_at" > ? and id IN (SELECT bb_model_id FROM sd_uuids WHERE bb_model_type = \'BaseModel\' and sd_class = \'SomeResource\')', '1900']}).and_return([])
          @application.send :sdata_scope
        end
      end

      context "when params contain :condition key but does not contain where clause" do
        before :each do
          @application.stub! :params => {:condition => '$linked', :sdata_resource => 'SomeResource'}
        end

        it "should return all entity records with simply guid" do
          BaseModel.should_receive(:find_with_deleted).with(:all, {:conditions => ['id IN (SELECT bb_model_id FROM sd_uuids WHERE bb_model_type = \'BaseModel\' and sd_class = \'SomeResource\')']}).and_return([])
          @application.send :sdata_scope
        end
      end
    end
  end
end
