require File.join(File.dirname(__FILE__), '..', 'spec_helper')

module Atom
  class Feed
    def opensearch(key)
      simple_extensions["{#{SData.config[:schemas]["opensearch"]},#{key}}"][0]
    end
  end
end

describe SData::Collection, "opensearch" do
  describe "given a model which acts as sdata" do
    before :all do
      @time = Time.now - 1.day
      remove_constants :SomeResource
      
      class SomeResource < SData::Resource::Base
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
        SomeResource.class_eval do
          has_sdata_options :feed => { :id => 'some-unique-id',
            :author => 'Test Author',
            :path => '/test_resource',
            :title => 'List of Test Items',
            :default_items_per_page => 5,
            :maximum_items_per_page => 100 }
        end
      end
      
      describe "given an empty record collection" do
        before do
          params = { :dataset => '-' }
          collection = SData::Collection.new([], SomeResource, params)
          @feed = collection.feed
        end

        it "should display default opensearch values" do
          @feed.opensearch("itemsPerPage").should == SomeResource.sdata_options[:feed][:default_items_per_page]
          @feed.opensearch("totalResults").should == 0
          @feed.opensearch("startIndex").should == 1
          @feed.entries.size.should == 0
          @feed.links.size.should == 1
          @feed.links[0].rel.should == 'self'
          @feed.links[0].href.should == "http://www.example.com/sdata/example/myContract/-/models"          
        end

        it "should correctly parse opensearch values to xml" do
          xml = parse_xml(@feed.to_xml)
          xml.should have_xpath('/xmlns:feed/opensearch:itemsPerPage')
          xml.should have_xpath('/xmlns:feed/opensearch:totalResults')
          xml.should have_xpath('/xmlns:feed/opensearch:startIndex')
        end
      end

      describe "given a non empty record collection of 15 records" do
        def models_with_serial_names
          models = []
          [].tap do |collection|
            15.times do |index|
              entry = SomeResource.new
              entry.name = index
              collection << entry
            end
          end
        end

        def verify_content_for(entries, range)
          counter = 0
          range.entries.size.should == entries.size
          range.each do |num|
            entries[counter].content.should == "contains #{num}"
            counter+=1
          end
        end
        
        def verify_links_for(links, conditions)
          present_types = links.collect{|l|l.rel}
          %w{self first last previous next}.each do |type|
            if conditions[type.to_sym].nil?
              present_types.include?(type).should == false
            else
              link = links.detect{|l|(l.rel==type)}
              link.should_not == nil
              link.href.split('?')[0].should == conditions[:path] if conditions[:path]
              query = link.href.split('?')[1]

              if conditions[:count]
                value = query.match(/count=\-?(\w|\d)*/).to_s.split('=')[1].to_s
                value.should == conditions[:count]
              elsif conditions[:count] == false #not nil
                (query.nil? || !query.include?('count')).should == true
              end

              if conditions[type.to_sym] == false
                (query.nil? || !query.include?('startIndex')).should == true
              else
                page = query.match(/startIndex=\-?\d*/).to_s.split('=')[1].to_s
                page.should == conditions[type.to_sym]
              end
            end
          end
        end

        def build_feed(params)
          params.merge! :dataset => '-'
          collection = SData::Collection.new(models_with_serial_names, SomeResource, params)
          collection.feed
        end
        
        it "should display default opensearch and link values" do
          @feed = build_feed {}
          
          @feed.opensearch("itemsPerPage").should == SomeResource.sdata_options[:feed][:default_items_per_page]
          @feed.opensearch("totalResults").should == 15
          @feed.opensearch("startIndex").should == 1
          @feed.entries.size.should == 5
          verify_content_for(@feed.entries, 1..5)
          verify_links_for(@feed.links, :path => "http://www.example.com/sdata/example/myContract/-/models", 
                           :count => false, :self => false, :first => '1', :last => '11', :next => '6')
        end

        it "properly calculate last page when itemsPerPage is not exact multiple of totalResults" do
          @feed = build_feed :count => '4'

          @feed.opensearch("itemsPerPage").should == 4
          @feed.opensearch("totalResults").should == 15
          @feed.opensearch("startIndex").should == 1
          @feed.entries.size.should == 4
          verify_content_for(@feed.entries, 1..4)
          verify_links_for(@feed.links, 
                           :count => '4', :self => false, :first => '1', :last => '13', :next => '5')
        end
        
        it "should reject zero start index" do
          @feed = build_feed :startIndex => '0'
          
          @feed.opensearch("itemsPerPage").should == SomeResource.sdata_options[:feed][:default_items_per_page]
          @feed.opensearch("totalResults").should == 15
          @feed.opensearch("startIndex").should == 1
          @feed.entries.size.should == 5
          verify_content_for(@feed.entries, 1..5)
          verify_links_for(@feed.links, :self => '0', :first => '1', :last => '11', :next => '6')
        end        

        it "should reject negative start index" do
          @feed = build_feed :startIndex => '-5'
          
          @feed.opensearch("itemsPerPage").should == SomeResource.sdata_options[:feed][:default_items_per_page]
          @feed.opensearch("totalResults").should == 15
          @feed.opensearch("startIndex").should == 1
          @feed.entries.size.should == 5
          verify_content_for(@feed.entries, 1..5)
          verify_links_for(@feed.links, :self => '-5', :first => '1', :last => '11', :next => '6')
        end  

        it "should accept positive start index which is not greater than totalResults-itemsPerPage+1 and return itemsPerPage records" do
          @feed = build_seed :startIndex => '11'
          
          @feed.opensearch("itemsPerPage").should == SomeResource.sdata_options[:feed][:default_items_per_page]
          @feed.opensearch("totalResults").should == 15
          @feed.opensearch("startIndex").should == 11
          @feed.entries.size.should == 5
          verify_content_for(@feed.entries, 11..15)
          verify_links_for(@feed.links, :self => '11', :first => '1', :last => '11', :previous => '6')
        end  

        it "should accept positive start index which is greater than totalResults-itemsPerPage+1 but not greater than totalResults, and return fitting itemsPerPage" do
          @feed = build_seed :startIndex => '12'
          
          @feed.opensearch("itemsPerPage").should == SomeResource.sdata_options[:feed][:default_items_per_page]
          @feed.opensearch("totalResults").should == 15
          @feed.opensearch("startIndex").should == 12
          @feed.entries.size.should == 4
          verify_content_for(@feed.entries, 12..15)
          verify_links_for(@feed.links, :self => '12', :first => '1', :last => '12', :previous => '7')

          @feed = build_seed :startIndex => '15'
          
          @feed.opensearch("itemsPerPage").should == SomeResource.sdata_options[:feed][:default_items_per_page]
          @feed.opensearch("totalResults").should == 15
          @feed.opensearch("startIndex").should == 15
          @feed.entries.size.should == 1
          verify_content_for(@feed.entries, 15..15)
          verify_links_for(@feed.links, :self => '15', :first => '1', :last => '15', :previous => '10')
        end  
        
        #RADAR: if this should generate error (e.g. OutOfBounds exception), this spec needs to change
        it "should accept positive start index which is greater than totalResults-itemsPerPage+1 but return nothing" do
          @feed = build_seed :startIndex => '16'
          
          @feed.opensearch("itemsPerPage").should == SomeResource.sdata_options[:feed][:default_items_per_page]
          @feed.opensearch("totalResults").should == 15
          @feed.opensearch("startIndex").should == 16
          @feed.entries.size.should == 0
          verify_links_for(@feed.links, :self => '16', :first => '1', :last => '11', :previous => '11')
        end  

        it "should combine start index with count" do
          @feed = build_feed :startIndex => '9', :count => '10'
          
          @feed.opensearch("itemsPerPage").should == 10
          @feed.opensearch("totalResults").should == 15
          @feed.opensearch("startIndex").should == 9
          @feed.entries.size.should == 7
          verify_content_for(@feed.entries, 9..15)
          verify_links_for(@feed.links, :count => '10', :self => '9', :first => '1', :last => '9', :previous => '1')
        end 

        it "should accept query to return no records" do
          @feed = build_feed :count => '0'
          
          @feed.opensearch("itemsPerPage").should == 0
          @feed.opensearch("totalResults").should == 15
          @feed.opensearch("startIndex").should == 1
          @feed.entries.size.should == 0
          verify_links_for(@feed.links, :count => '0', :self => false)
        end

        it "should accept query to return more records than default value but less than maximum value" do
          @feed = build_feed :count => '50'
          
          @feed.opensearch("itemsPerPage").should == 50
          @feed.opensearch("totalResults").should == 15
          @feed.opensearch("startIndex").should == 1
          @feed.entries.size.should == 15
          verify_content_for(@feed.entries, 1..15)
          verify_links_for(@feed.links, 
                           :count => '50', :self => false)
        end

        it "should reject query to return more records than maximum value, and use maximum instead" do
          @feed = build_feed(:count => '300')
          
          @feed.opensearch("itemsPerPage").should == 100
          @feed.opensearch("totalResults").should == 15
          @feed.opensearch("startIndex").should == 1
          @feed.entries.size.should == 15
          verify_content_for(@feed.entries, 1..15)
          verify_links_for(@feed.links, 
                           :count => '300', :self => false)
        end
      end

      #FIXME: breaks right now. would be nice to fix without breaking any other tests
      #find out what's a method to determine whether a string is numerical ('asdf'.to_i returns 0 which is bad)
      it "should reject invalid value and return default instead" do
        @feed = build_feed :count => 'asdf'
        
        @feed.opensearch("itemsPerPage").should == 5
        @feed.opensearch("totalResults").should == 15
        @feed.opensearch("startIndex").should == 1
        @feed.entries.size.should == 5
        verify_content_for(@feed.entries, 1..5)
        verify_links_for(@feed.links, :path => "http://www.example.com/sdata/example/myContract/-/models", 
                         :count => 'asdf', :self => false, :first => '1', :last => '11', :next => '6')
      end
      
      it "should reject negative value and return default instead" do
        @feed = build_feed :count => '-3'
        
        @feed.opensearch("itemsPerPage").should == 5
        @feed.opensearch("totalResults").should == 15
        @feed.opensearch("startIndex").should == 1
        @feed.entries.size.should == 5
        verify_content_for(@feed.entries, 1..5)
        verify_links_for(@feed.links, :path => "http://www.example.com/sdata/example/myContract/-/models", 
                         :count => '-3', :self => false, :first => '1', :last => '11', :next => '6')
      end
      
      #RADAR: in this case, going from initial page to previous page will show 'next' page as not equal
      #to initial page, since startIndex is currently not supported to be negative (and show X records on
      #first page where X = itemsPerPage+startIndex, and startIndex is negative and thus substracted) 
      #if this is needed, spec will change (but in theory this would conflict with SData spec which
      #specifies that ALL pages must have exactly the same items as itemsPerPage with possible exception 
      #of ONLY the last page, and not the first one.
      it "should combine start index with count not exceeding totals" do
        @feed = build_feed :startIndex => '3', :count => '5'
        
        @feed.opensearch("itemsPerPage").should == 5
        @feed.opensearch("totalResults").should == 15
        @feed.opensearch("startIndex").should == 3
        @feed.entries.size.should == 5
        verify_content_for(@feed.entries, 3..7)
        verify_links_for(@feed.links, :path => "http://www.example.com/sdata/example/myContract/-/models", 
                         :count => '5', :self => '3', :first => '1', :last => '13', :previous => '1', :next => '8')
      end  
      
      it "should combine start index with count exceeding totals" do
        @feed = build_feed :startIndex => '9', :count => '10'
        
        @feed.opensearch("itemsPerPage").should == 10
        @feed.opensearch("totalResults").should == 15
        @feed.opensearch("startIndex").should == 9
        @feed.entries.size.should == 7
        verify_content_for(@feed.entries, 9..15)
        verify_links_for(@feed.links, :path => "http://www.example.com/sdata/example/myContract/-/models", 
                         :count => '10', :self => '9', :first => '1', :last => '9', :previous => '1')
      end  
    end
  end
end
