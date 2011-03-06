require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Application, "#sdata_update_instance" do
  before :all do
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

    Object.__send__ :remove_const, :SomeResource if defined?(SomeResource)
    class SomeResource < SData::Resource::Base
      attr_accessor :baze

      self.baze_class = BaseClass
    end
  end

  before :each do
    pending # not currently supported
    @application = SData::TestApplication.new
  end  

  describe "given params contain Atom::Entry" do
    before :each do
      @entry = Atom::Entry.new
      @application.stub!  :params => { :entry => @entry, :instance_id => 1, :sdata_resource => 'SomeResource' },
        :response => OpenStruct.new,
        :request => OpenStruct.new(:fresh? => true)
      
      @model = VirtualModel.new(BaseClass.new)
      VirtualModel.should_receive(:new).and_return @model
    end

    describe "when update is successful" do
      before :each do
        @model.baze.stub! :save => true
        @model.stub! :to_atom => stub(:to_xml => '<entry></entry>')
      end

      it "should respond with updated" do
        @controller.should_receive(:render) do |args|
          #TODO: what should I check for?.. Returns 1 right now, is this right?
        end
        @controller.sdata_update_instance
      end
    end
  end
end

