require File.join(File.dirname(__FILE__), '..', 'spec_helper')
include SData

module Atom
  class Feed
    def opensearch(key)
      simple_extensions["{#{$SDATA_SCHEMAS["opensearch"]},#{key}}"][0]
    end
  end
end

describe ControllerMixin, "#sdata_collection" do
  describe "given a model which acts as sdata" do
    before :all do
      @time = Time.now - 1.day
      
      class Model
        extend ActiveRecordMixin
        acts_as_sdata
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
        
        def name=(a_name)
          @name=a_name
        end
        def name
          @name || "John Smith"
        end
        def sdata_content
          "contains #{self.name}"
        end
      end
    end

    describe "given a controller which acts as sdata" do
      before :all do
        Base = Class.new(ActionController::Base)
        Base.extend ControllerMixin


        Base.acts_as_sdata  :model => Model,
                            :feed => { :id => 'some-unique-id',
                                       :author => 'Test Author',
                                       :path => '/test_resource',
                                       :title => 'List of Test Items',
                                       :default_items_per_page => 5,
                                       :maximum_items_per_page => 100}
                                       
      end

      before :each do
        @controller = Base.new

        @controller.stub! :request => OpenStruct.new(
                            :protocol => 'http://', 
                            :host_with_port => $APPLICATION_HOST, 
                            :request_uri => Base.sdata_options[:feed][:path],
                            :path => $SDATA_STORE_PATH + 'testResource',
                            :query_parameters => {}),
                          :params => {}
      end
      
      describe "given an empty record collection" do
        before :each do
          @controller.sdata_options[:model].stub! :all => []
        end
        it "should display default opensearch values" do
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == Base.sdata_options[:feed][:default_items_per_page]
            hash[:xml].opensearch("totalResults").should == 0
            hash[:xml].opensearch("startIndex").should == 1
            hash[:xml].entries.size.should == 0
            hash[:xml].links.size.should == 1
            hash[:xml].links[0].rel.should == 'self'
            hash[:xml].links[0].href.should == "http://www.example.com/sdata/example/myContract/-/testResource"
          end
          @controller.sdata_collection
        end

        it "should correctly parse opensearch values to xml" do
          @controller.should_receive(:render) do |hash|
            hash[:xml].to_xml.gsub(/\n\s*/, '').match(/<feed.*<opensearch:itemsPerPage>5<\/opensearch:itemsPerPage><opensearch:totalResults>0<\/opensearch:totalResults><opensearch:startIndex>1<\/opensearch:startIndex>.*<\/feed>$/).should_not == nil
          end
          @controller.sdata_collection
        end

      end

      describe "given a non empty record collection of 15 records" do
        
        def models_with_serial_names
          models = []
          for i in 1..15 do
            model = Model.new
            model.name = i.to_s
            models << model
          end
          models
        end
        
        def verify_content_for(entries, range)
          counter = 0
          range.entries.size.should == entries.size
          range.each do |num|
            entries[counter].content.should == "contains #{num}"
            counter+=1
          end
        end
        
        #self, first, last, previous, next
        def verify_links_for(links, conditions)
          present_types = links.collect{|l|l.rel}
          %w{self first last previous next}.each do |type|
            if !conditions[type.to_sym]
#              debugger
#              sleep 1
              present_types.include?(type).should == false
            else
              link = links.collect{|l|((l.rel==type) ? l : nil)}.compact[0]
              link.should_not == nil
#              debugger
#              sleep 1
            end
          end
        end  
        before :each do
          @controller.sdata_options[:model].stub! :all => models_with_serial_names

        end
        
        it "should display default opensearch values" do
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == Base.sdata_options[:feed][:default_items_per_page]
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 1
            hash[:xml].entries.size.should == 5
            verify_content_for(hash[:xml].entries, 1..5)
#            verify_links_for(hash[:xml].links, :self => 'asdf')
          end
          @controller.sdata_collection
        end
        
        it "should reject zero start index" do
          @controller.stub! :params => {:startIndex => '0'}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == Base.sdata_options[:feed][:default_items_per_page]
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 1
            hash[:xml].entries.size.should == 5
            verify_content_for(hash[:xml].entries, 1..5)
          end
          @controller.sdata_collection
        end        

        it "should reject negative start index" do
          @controller.stub! :params => {:startIndex => '-5'}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == Base.sdata_options[:feed][:default_items_per_page]
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 1
            hash[:xml].entries.size.should == 5
            verify_content_for(hash[:xml].entries, 1..5)
          end
          @controller.sdata_collection
        end  

        it "should accept positive start index which is not greater than totalResults-itemsPerPage+1 and return itemsPerPage records" do
          @controller.stub! :params => {:startIndex => '11'}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == Base.sdata_options[:feed][:default_items_per_page]
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 11
            hash[:xml].entries.size.should == 5
            verify_content_for(hash[:xml].entries, 11..15)
          end
          @controller.sdata_collection
        end  

        it "should accept positive start index which is greater than totalResults-itemsPerPage+1 but not greater than totalResults, and return fitting itemsPerPage" do
          @controller.stub! :params => {:startIndex => '12'}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == Base.sdata_options[:feed][:default_items_per_page]
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 12
            hash[:xml].entries.size.should == 4
            verify_content_for(hash[:xml].entries, 12..15)
          end
          @controller.sdata_collection

          @controller.stub! :params => {:startIndex => '15'}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == Base.sdata_options[:feed][:default_items_per_page]
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 15
            hash[:xml].entries.size.should == 1
            verify_content_for(hash[:xml].entries, 15..15)
          end
          @controller.sdata_collection

        end  
        
        #RADAR: if this should generate error (e.g. OutOfBounds exception), this spec needs to change
        it "should accept positive start index which is greater than totalResults-itemsPerPage+1 but return nothing" do
          @controller.stub! :params => {:startIndex => '16'}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == Base.sdata_options[:feed][:default_items_per_page]
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 16
            hash[:xml].entries.size.should == 0
          end
          @controller.sdata_collection
        end  

        it "should combine start index with count" do
          @controller.stub! :params => {:startIndex => '9', :count => 10}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == 10
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 9
            hash[:xml].entries.size.should == 7
            verify_content_for(hash[:xml].entries, 9..15)
          end
          @controller.sdata_collection
        end 

        it "should accept query to return no records" do
          @controller.stub! :params => {:count => '0'}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == 0
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 1
            hash[:xml].entries.size.should == 0
          end
          @controller.sdata_collection
        end

        it "should accept query to return less records than default value" do
          @controller.stub! :params => {:count => '3'}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == 3
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 1
            hash[:xml].entries.size.should == 3
            verify_content_for(hash[:xml].entries, 1..3)
          end
          @controller.sdata_collection
        end

        it "should accept query to return more records than default value but less than maximum value" do
          @controller.stub! :params => {:count => '50'}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == 50
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 1
            hash[:xml].entries.size.should == 15
            verify_content_for(hash[:xml].entries, 1..15)
          end
          @controller.sdata_collection
        end

        it "should reject query to return more records than maximum value, and use maximum instead" do
          @controller.stub! :params => {:count => '300'}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == 100
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 1
            hash[:xml].entries.size.should == 15
            verify_content_for(hash[:xml].entries, 1..15)
          end
          @controller.sdata_collection
        end

        #FIXME: breaks right now. would be nice to fix without breaking any other tests
        #find out what's a method to determine whether a string is numerical ('asdf'.to_i returns 0 which is bad)
        it "should reject invalid value and return default instead" do
          @controller.stub! :params => {:count => 'asdf'}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == 5
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 1
            hash[:xml].entries.size.should == 5
            verify_content_for(hash[:xml].entries, 1..15)
          end
          @controller.sdata_collection
        end
        
        it "should reject negative value and return default instead" do
          @controller.stub! :params => {:count => '-3'}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == 5
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 1
            hash[:xml].entries.size.should == 5
            verify_content_for(hash[:xml].entries, 1..5)
          end
          @controller.sdata_collection
        end

        it "should combine start index with count not exceeding totals" do
          @controller.stub! :params => {:startIndex => '3', :count => 5}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == 5
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 3
            hash[:xml].entries.size.should == 5
            verify_content_for(hash[:xml].entries, 3..7)
          end
          @controller.sdata_collection
        end  
 
        it "should combine start index with count exceeding totals" do
          @controller.stub! :params => {:startIndex => '9', :count => 10}
          @controller.should_receive(:render) do |hash|
            hash[:xml].opensearch("itemsPerPage").should == 10
            hash[:xml].opensearch("totalResults").should == 15
            hash[:xml].opensearch("startIndex").should == 9
            hash[:xml].entries.size.should == 7
            verify_content_for(hash[:xml].entries, 9..15)
          end
          @controller.sdata_collection
        end  
  
      end
    
    end
  end
end