require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Application, "#build_sdata_feed" do
  describe "given a controller which acts as sdata" do
    before :all do
      Object.__send__ :remove_const, :SomeResource if defined?(SomeResource)

      class SomeResource < SData::Resource::Base
        has_sdata_options :feed => { :id => 'some-unique-id',
                                     :author => 'Test Author',
                                     :path => '/test_resource',
                                     :title => 'List of Test Items' }
      end
      SomeResource.__send__ :define_method, :build_sdata_feed, lambda { super }
    end

    before :each do
      @application = SData::TestApplication
      @application.stub! :request => OpenStruct.new(
                                    :protocol => 'http', 
                                    :host_with_port => 'http://example.com', 
                                    :request_uri => SomeResource.sdata_options[:feed][:path],
                                    :path => SData.store_path + '/-/testResource'),
                        :params => {:dataset => '-'},
                        :sdata_options => {:feed => {}, :model => OpenStruct.new(:name => 'base', :sdata_resource_kind_url => '')}

                                    
    end
    
    it "should return Atom::Feed instance" do
      @application.build_sdata_feed.should be_kind_of(Atom::Feed)
    end

    it "should not contain any entries" do
      @application.build_sdata_feed.entries.should be_empty
    end

    it "should adopt passed sdata_options" do
      @application.build_sdata_feed.id = SomeResource.sdata_options[:feed][:id]
    end
    
    it "should assign categories" do
      @application.build_sdata_feed.categories.size.should == 1
      @application.build_sdata_feed.categories[0].term.should == 'bases'
      @application.build_sdata_feed.categories[0].label.should == 'Bases'
      @application.build_sdata_feed.categories[0].scheme.should == "http://schemas.sage.com/sdata/categories"
    end
  end
end
