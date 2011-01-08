require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Resource::Base, "#find_by_sdata_instance_id" do
  describe "given an SData::Resource::Base derivative" do
    before :all do
      remove_constants :BaseModel
      BaseModel = Class.new(ActiveRecord::Base)
    end

    describe "when sdata_options contain :instance_id" do
      before :all do
        class ResourceWithInstanceId < SData::Resource::Base;
          has_sdata_options :instance_id => :email

          self.baze_class = BaseModel
        end
      end

      it "should find by a field assigned to :instance_id option value" do
        email = "e@ma.il"
        BaseModel.should_receive(:find).with(:first, :conditions => { :email => email }).once
        ResourceWithInstanceId.find_by_sdata_instance_id(email)
      end
    end

    describe "when sdata_options does not contain :instance_id" do
      before :all do
        class ResourceWithoutInstanceId < SData::Resource::Base;
          self.baze_class = BaseModel
        end
      end

      it "should consider :id as SData instance ID" do
        id = 1
        BaseModel.should_receive(:find).with(id).once
        ResourceWithoutInstanceId.find_by_sdata_instance_id(id)
      end
    end
  end
end
