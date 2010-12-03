require File.join(File.dirname(__FILE__), 'spec_helper')

describe SData::Resource do
  describe ".initial_scope" do
    context "given a resource with a baze class" do
      before :all do
        class TestModel < ActiveRecord::Base; end
        class TestResource < SData::Resource::Base
          self.baze_class = TestModel
        end
      end

      context "when .initial_scope is called withing class body" do
        before :all do
          TestResource.class_eval do
            initial_scope do |user|
              { :conditions => { :created_by_id => user.id } }
            end
          end  
        end

        it "should define a scope named :sdata_scope_for_context in a baze class" do
          TestModel.should respond_to(:sdata_scope_for_context)
        end

        it "should pass given block to a scope" do
          fake_user = stub('user', :id => 1)
          TestModel.sdata_scope_for_context(fake_user).proxy_options.should == { :conditions => { :created_by_id => 1 } }
        end
      end
    end
  end

  describe "#registered_resources" do
    context "when I inherit couple of classes" do
      before :each do
        class TradingAccount < SData::Resource::Base; end
        class SalesInvoice < SData::Resource::Base; end
      end

      it "should give access to children by symbol" do
        SData::Resource::Base.registered_resources[:trading_account].should == TradingAccount
        SData::Resource::Base.registered_resources[:sales_invoice].should == SalesInvoice
      end

      context "when child classes are in namespaces" do
        before :each do
          module SData
            module Contracts
              module CrmErp
                class PostalAddress < SData::Resource::Base; end
              end
            end
          end
        end

        it "should give access to these children by keys without namespace" do
          SData::Resource::Base.registered_resources[:postal_address].should == SData::Contracts::CrmErp::PostalAddress
        end
      end

      describe "derived class" do
        subject { TradingAccount }

        it "should respond to SData-related class methods" do
          subject.should respond_to(:sdata_resource_kind_url)
        end
      end
    end
  end

  describe ".has_sdata_options" do
    context "when I derive from SData::Resource::Base" do
      before :all do
        class TradingAccount < SData::Resource::Base; end
      end

      it "should respond to .has_sdata_options" do
        TradingAccount.should respond_to(:has_sdata_options)
      end

      context "when I call with a hash" do
        before :all do
          TradingAccount.class_eval { has_sdata_options :instance_id => :id }
        end

        it "should return given hash then" do
          TradingAccount.sdata_options.should == { :instance_id => :id }
        end
        
        describe "sdata resource instance" do
          before do
            @resource_instance = TradingAccount.new
          end

          it "should respond to #sdata_options" do
            @resource_instance.should respond_to(:sdata_options)
          end

          it "should return the same options" do
            @resource_instance.sdata_options.should == { :instance_id => :id }
          end
        end
      end
    end

    context "when two SData resources with different options" do
      before :each do
        class TradingAccount < SData::Resource::Base
          has_sdata_options :value => 'TradingAccount'
        end

        class SalesInvoice < SData::Resource::Base
          has_sdata_options :value => 'SalesInvoice'
        end
      end

      it "should respond to #sdata_options" do
        TradingAccount.should respond_to(:sdata_options)
        SalesInvoice.should respond_to(:sdata_options)
      end

      it "should return correspondent value" do
        TradingAccount.sdata_options.should == { :value => 'TradingAccount' }
        SalesInvoice.sdata_options.should == { :value => 'SalesInvoice' }
      end
    end
  end
end
