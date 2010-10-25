require File.join(File.dirname(__FILE__),  'spec_helper')

describe SData::Collection::Feed do
  class ErroneousEntry < Customer
    def to_xml
      raise "Something went wrong"
    end    
  end  

  before do
    @feed_options = { :id => 'some-unique-id',
            :author => 'Test Author',
            :path => '/test_resource',
            :title => 'List of Test Items',
            :default_items_per_page => 10,
            :maximum_items_per_page => 100 }
  end

  context "when all entries are healthy" do
    subject { SData::Collection::Feed.new([Customer.new, Customer.new], @feed_options) }

    it "should be a regular Atom Feed with two entries"
  end

  context "when some of entries are erroneous" do
    subject { SData::Collection::Feed.new([Customer.new, ErroneousEntry.new], @feed_options) }

    
  end

  context "when there is no entries" do
    subject { SData::Collection::Feed.new([], @feed_options) }
  end
end
