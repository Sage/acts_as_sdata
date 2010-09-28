require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Resource::Base, "#find_by_sdata_instance_id" do
  describe "given an SData::Resource::Base derivative" do
    before :all do
      class Model < SData::Resource::Base; end
    end

    describe "when sdata_options contain :instance_id" do
      before :each do
        Model.class_eval { has_sdata_options :instance_id => :email }
      end

      it "should find by a field assigned to :instance_id option value" do
        email = "e@ma.il"
        Model.should_receive(:find).with(:first, :conditions => { :email => email }).once
        Model.find_by_sdata_instance_id(email)
      end
    end

    describe "when sdata_options does not contain :instance_id" do
      before :each do
        Model.class_eval { has_sdata_options }
      end

      it "should consider :id as SData instance ID" do
        id = 1
        Model.should_receive(:find).with(id).once
        Model.find_by_sdata_instance_id(id)
      end
    end
  end
end
