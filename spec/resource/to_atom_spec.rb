require File.join(File.dirname(__FILE__), '..', 'spec_helper')
                                                          
describe SData::Resource::Base, "#to_atom" do
  describe "given a Resource" do
    before :all do
      remove_constants :Base

      module SData; module Contracts; module CrmErp; end; end; end;
      class SData::Contracts::CrmErp::Base < SData::Resource::Base;
        define_payload_map Hash.new
      end

      @context = SData::Application::Context.new({ :dataset => '-' }, Hash.new)
    end

    describe "when there is no sdata options" do
      before :each do
        SData::Contracts::CrmErp::Base.class_eval { has_sdata_options Hash.new }
        @model = SData::Contracts::CrmErp::Base.new
        @model.stub! :id => 1, :name => 'John Smith', :updated_at => Time.now - 1.day, :created_by => @model, :sage_username => 'basic_user' 
        @model.stub! :sdata_content => "Base ##{@model.id}: #{@model.name}", :attributes => {}
      end

      it "should return an Atom::Entry instance" do
        @model.to_atom(@context).should be_kind_of(Atom::Entry)
      end

      it "should assign model name to Atom::Entry#content" do
        @model.to_atom(@context).content.should == 'Base #1: John Smith'
      end

      it "should assign model name and id to Atom::Entry#title" do
        @model.to_atom(@context).title.should == 'Base 1'
      end

      it "should assign Atom::Entry#updated" do
        Time.parse(@model.to_atom(@context).updated).should < Time.now-1.day
        Time.parse(@model.to_atom(@context).updated).should > Time.now-1.day-1.minute        
      end

      it "should assign Atom::Entry::id" do
        @model.to_atom(@context).id.should == "http://www.example.com/sdata/example/myContract/-/bases('1')"
      end

      it "should assign Atom::Entry::categories" do
        @model.to_atom(@context).categories.size.should == 1
        @model.to_atom(@context).categories[0].term.should == "base"
        @model.to_atom(@context).categories[0].label.should == "Base"
        @model.to_atom(@context).categories[0].scheme.should == "http://schemas.sage.com/sdata/categories"
      end
    end

    describe "when there are sdata_options" do
      before :each do
        SData::Contracts::CrmErp::Base.class_eval do
          has_sdata_options :title => lambda { "#{id}: #{name}" },
                            :content => lambda { "#{name}" }
        end

        @model = SData::Contracts::CrmErp::Base.new
        @model.stub! :id => 1, :name => 'Test', :updated_at => Time.now - 1.day, :created_by => @model, :sage_username => 'basic_user'
        @model.stub! :sdata_content => "Base ##{@model.id}: #{@model.name}",  :to_xml => ''
      end

      it "should evaulate given lambda's in the correct context" do
        @model.to_atom(@context).title.should == '1: Test'
        @model.to_atom(@context).content.should == 'Base #1: Test'
      end
    end
  end
end
