require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Application, "#sdata_show_instance" do
  before :all do
    module Sage
      module BusinessLogic
        module Exception
          class IncompatibleDataException < StandardError; end
        end
      end
    end
  end

  describe "given a SData application which acts as sdata" do
    before :all do
      @application = SData::TestApplication.new
    end

    describe "given a model without baze" do
      before :all do
        Object.__send__ :remove_const, :SomeResource if defined?(SomeResource)
        class SomeResource < SData::Resource::Base; end;
      end

      describe "when params contain :instance_id key" do
        before :each do
          @instance_id = 1
          @application.stub! :params => { :instance_id => @instance_id, :sdata_resource => 'SomeResource' },
                            :current_user => OpenStruct.new(:sage_username => 'bob', :id => 1),
                            :target_user => OpenStruct.new(:sage_username => 'bob', :id => 1),
                            :logged_in? => true
        end

#        describe "when record with such id exists and belongs to user" do
#          before :each do
#            @record = SomeResource.new
#            @record.stub! :owner => OpenStruct.new(:sage_username => 'bob', :id => 1)
#            SomeResource.should_receive(:find_by_sdata_instance_id).with(@instance_id).and_return(@record)
#          end
#  
#          it "should render atom entry of the record" do
#            entry = Atom::Entry.new
#            @record.should_receive(:to_atom).and_return(entry)
#            @controller.should_receive(:render).with(:xml => entry, :content_type => "application/atom+xml; type=entry")
#            @controller.sdata_show_instance
#          end
#        end

        describe "when record with such id exists but does not belong to user" do
          before :each do
            @record = SomeResource.new
            @record.stub! :owner => OpenStruct.new(:sage_username => 'mary', :id => 2, :biller => OpenStruct.new(:bookkeepers => []))
            SomeResource.should_receive(:find_by_sdata_instance_id).with(@instance_id).and_return(@record)
          end
  
          it "should raise an exception" do
            lambda { @application.sdata_show_instance }.should raise_error(Sage::BusinessLogic::Exception::IncompatibleDataException)
          end
        end
  
        describe "when record with such id does not exist" do
          it "should..." do
            pending "wasn't defined yet"
          end
        end
      end
  
      describe "whem params does not contain :instance_id key" do
        before :each do
          @application.stub! :params => Hash.new
        end
  
        it "should..." do
          pending "wasn't defined yet"
        end
      end
    end
    
    describe "given a model with baze" do
      it "should ..." do
        pending "not yet tested"
      end
    end
  end
end
