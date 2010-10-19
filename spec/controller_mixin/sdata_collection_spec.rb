require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Application, "#sdata_collection" do
  describe "given an SData resource" do
    before :all do
      @time = Time.now - 1.day

      Object.__send__ :remove_const, :SomeResource if defined?(SomeResource)
      class SomeResource < SData::Resource::Base
        has_sdata_options :feed => { :id => 'some-unique-id',
                                       :author => 'Test Author',
                                       :path => '/test_resource',
                                       :title => 'List of Test Items',
                                       :default_items_per_page => 10,
                                       :maximum_items_per_page => 100}

        def self.name
          "SData::Contracts::CrmErp::ModelBob"
        end
        
        def id
          1
        end
        
        def attributes; {} end
        
        def updated_at
          @time
        end
        
        def created_by
          OpenStruct.new(:id => 1, :sage_username => 'sage_user')
        end
        
        def name
          "John Smith"
        end
        
        def sdata_content
          "ModelBob ##{self.id}: #{self.name}"
        end
        
        def payload_map
          {}
        end
      end
    end

    describe "given an SData application" do
      before :each do
        @application = SData::TestApplication.new
        @application.stub! :request => OpenStruct.new(
                            :protocol => 'http', 
                            :host_with_port => 'http://example.com', 
                            :request_uri => SomeResource.sdata_options[:feed][:path],
                            :path => SData.store_path + '/-/testResource',
                            :query_parameters => {}),
                          :params => { :sdata_resource => 'SomeResource' }
        @application.sdata_options[:model].stub! :all => [SomeResource.new, SomeResource.new]
      end

      it "should render Atom feed" do
        @application.should_receive(:render) do |hash|
          hash[:content_type].should == "application/atom+xml; type=feed"
          hash[:xml].should be_kind_of(Atom::Feed)
          hash[:xml].entries.should == SomeResource.all.map{|entry| entry.to_atom({})}
        end
        @application.sdata_collection
      end
    end
  end
end
