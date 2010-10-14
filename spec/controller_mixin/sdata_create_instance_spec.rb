require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Application, "#sdata_create_instance" do
  describe "given a controller which acts as sdata with a virtual model as a base" do
    before :all do
      Model = Class.new
      
      class VirtualModel < SData::Resource::Base
        attr_accessor :baze
        self.baze_class = Model
      end
    end

    before :each do
      @app = SData::TestApplication.new
      pending
    end  

    describe "given params contain Atom::Entry" do
      before :each do
        @entry = Atom::Entry.new
        @app.stub! :params => { :entry => @entry, :sdata_resource => 'VirtualModel' }
        
        @model = VirtualModel.new(Model.new)
        VirtualModel.should_receive(:new).and_return @model
      end

      describe "when save is successful" do
        before :each do
          @model.baze.stub! :save => true
          @model.stub! :to_atom => stub(:to_xml => '<entry></entry>')
        end

        it "should respond with 201 (created)" do
          @app.should_receive(:render) do |args|
            args[:status].should == :created
          end
          @app.sdata_create_instance
        end

        it "should return updated model as a body" do
          @app.should_receive(:render) do |args|
            args[:content_type].should == "application/atom+xml; type=entry"
            args[:xml].should == @model.to_atom.to_xml
          end

          @app.sdata_create_instance
        end
      end


      describe "when save fails" do
        before :each do
          @model.baze.stub! :save => false
          @model.stub! :errors => stub(:to_xml => '<errors></errors>')
        end

        it "should respond with 400 (Bad Request)" do
          @app.should_receive(:render) do |args|
            args[:status].should == :bad_request
          end

          @app.sdata_create_instance
        end

        it "should return validation errors as a body" do
          @app.should_receive(:render) do |args|
            args[:xml].should == @model.errors.to_xml
          end

          @app.sdata_create_instance
        end
      end
      
      
    end

  end

  describe "given a controller which acts as sdata" do
    before :each do
      pending
      @app = Base.new
    end

    describe "given params contain Atom::Entry" do
      before :each do
        @entry = Atom::Entry.new
        @app.stub! :params => { :entry => @entry }

        @model = Model.new
        Model.should_receive(:new).and_return @model
      end

      describe "when save is successful" do
        before :each do
          @model.stub! :save => true
          @model.stub! :to_atom => stub(:to_xml => '<entry></entry>')
        end

        it "should respond with 201 (created)" do
          @app.should_receive(:render) do |args|
            args[:status].should == :created
          end

          @app.sdata_create_instance
        end

        it "should return updated model as a body" do
          @app.should_receive(:render) do |args|
            args[:content_type].should == "application/atom+xml; type=entry"
            args[:xml].should == @model.to_atom.to_xml
          end

          @app.sdata_create_instance
        end
      end

      describe "when save fails" do
        before :each do
          @model.stub! :save => false
          @model.stub! :errors => stub(:to_xml => '<errors></errors>')
        end

        it "should respond with 400 (Bad Request)" do
          @app.should_receive(:render) do |args|
            args[:status].should == :bad_request
          end

          @app.sdata_create_instance
        end

        it "should return validation errors as a body" do
          @app.should_receive(:render) do |args|
            args[:xml].should == @model.errors.to_xml
          end

          @app.sdata_create_instance
        end
      end
    end
  end
end
