require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe SData::ControllerMixin, "#sdata_scope" do
  context "given a controller which acts as sdata and accesses a non-linked model" do
    before :all do
      Object.__send__ :remove_const, :SomeResource if defined?(SomeResource)

      @app = SData::TestApplication.new
      
      class SomeResource < SData::Resource::Base
        self.baze_class = Class.new

        define_payload_map :born_at => { :baze_field => :born_at }

        has_sdata_options :feed =>
          { :author => 'Billing Boss',
          :path => '/trading_accounts',
          :title => 'Billing Boss | Trading Accounts',
          :default_items_per_page => 10,
          :maximum_items_per_page => 100 }
      end

      SomeResource.stub! :all => []
    end

    context "when params contain where clause" do
      before :each do
        @app.stub! :params => { 'where bornAt gt 1900' => nil, :sdata_resource => 'SomeResource' }
      end

      it "should apply to SData::Predicate for conditions" do
        SomeResource.should_receive(:all).with :conditions => ["\"born_at\" > ?", '1900']
        @app.send :sdata_scope
      end

      context "when condition contain 'ne' relation" do
        before :each do
          @app.stub! :params => { 'where born_at ne 1900' => nil, :sdata_resource => 'SomeResource' }
        end

        it "should parse it correctly" do
          SomeResource.should_receive(:all).with :conditions => ["\"born_at\" <> ?", '1900']
          @app.send :sdata_scope
        end
      end
    end

    context "when params do not contain :predicate key" do
      before :each do
        @app.stub! :params => { :sdata_resource => 'SomeResource' }
      end

      it "should return all entity records" do
        SomeResource.should_receive(:all).with({})
        @app.send :sdata_scope
      end
    end
  end
end
