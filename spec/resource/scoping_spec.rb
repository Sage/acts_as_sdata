require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Resource::Base, "#sdata_scope_for_context" do
  context "when 'enforce scoping' config option is on" do
    before do
      SData.stub! :enforce_scoping? => true
    end
      
    context "when resource has initial sdata scope" do
      before do
        remove_constants :TestResource, :BazeModel

        class BazeModel < ActiveRecord::Base; end
        
        class TestResource < SData::Resource::Base
          self.baze_class = BazeModel
          
          initial_scope do |target_user|
            { :conditions => { :owner => target_user } }
          end
        end
      end

      it "should return a well-formed SData resource scope" do
        TestResource.sdata_scope_for_context(stub).should be_a(SData::Resource::Scope)
      end
    end

    context "when resource doesn't have initial sdata scope" do
      before do
        remove_constants :TestResource, :BazeModel

        class BazeModel < ActiveRecord::Base; end
        
        class TestResource < SData::Resource::Base
          self.baze_class = BazeModel
        end
      end

      it "should raise a error" do
        lambda { TestResource.sdata_scope_for_context(stub) }.should raise_error
      end
    end
  end

  context "when 'enforce scoping' config option is off" do
    context "when resource has initial sdata scope" do
      before do
        remove_constants :TestResource, :BazeModel

        class BazeModel < ActiveRecord::Base; end
        
        class TestResource < SData::Resource::Base
          self.baze_class = BazeModel
          
          initial_scope do |target_user|
            { :conditions => { :owner => target_user } }
          end
        end
      end

      it "should return a well-formed SData resource scope" do
        TestResource.sdata_scope_for_context(stub).should be_a(SData::Resource::Scope)
      end
    end

    context "when resource doesn't have initial sdata scope" do
      before do
        remove_constants :TestResource, :BazeModel

        class BazeModel < ActiveRecord::Base; end
        
        class TestResource < SData::Resource::Base
          self.baze_class = BazeModel
        end
      end

      it "should still return a well-formed SData resource scope" do
        TestResource.sdata_scope_for_context(stub).should be_a(SData::Resource::Scope)
      end
    end
  end
end
