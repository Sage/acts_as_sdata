require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Application, "#sdata_collection_sync_feed" do
  class BaseClass
    attr_accessor :status
    def id
      1
    end
    
    def self.find(*params)
      self.new
    end
    
    def update_attributes(*params)
      self.status = :updated
      self
    end
  end

  class VirtualModel < SData::Resource::Base
    attr_accessor :baze

    self.baze_class = BaseClass
  end

  before :each do
    @application = SData::TestApplication.new
  end

  describe "given params contain a target digest" do
    before :each do
      pending
      @entry = Atom::Entry.new
      @application.stub!  :params => { :entry => @entry, :instance_id => 1},
      :response => OpenStruct.new,
      :request => OpenStruct.new(:fresh? => true),
      :current_user => OpenStruct.new(:id => 1)
      
      @model = VirtualModel.new(BaseClass.new)
      VirtualModel.should_receive(:new).and_return @model
    end

    describe "when update is successful" do
      before :each do
        @model.baze.stub! :save => true
        @model.stub! :to_atom => stub(:to_xml => '<entry></entry>')
        @model.stub! :owner => OpenStruct.new(:id => 1)
      end

      it "should respond with updated" do
        @application.should_receive(:render) do |args|
          #TODO: what should I check for?.. Returns 1 right now, is this right?
        end
        @application.sdata_update_instance
      end
    end
  end
end
