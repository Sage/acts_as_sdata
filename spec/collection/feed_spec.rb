require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Collection::Feed do
  before do
    @feed_options = { :id => 'some-unique-id',
            :author => 'Test Author',
            :path => '/test_resource',
            :title => 'List of Test Items',
            :default_items_per_page => 10,
            :maximum_items_per_page => 100 }
    @resource_url = Customer.sdata_resource_kind_url('-')
  end

  def build_feed(entries)
    SData::Collection::Feed.new(entries, @resource_url, @feed_options)
  end

  def feed_xml
    parse_xml(@feed.to_xml)
  end

  shared_examples_for "any SData feed" do
    it "should be an Atom Feed" do
      feed_xml.should have_xpath('/xmlns:feed[@xmlns="http://www.w3.org/2005/Atom"]')
    end

    it "should respect given feed options"
  end

  context "when all entries are healthy" do
    before { @feed = build_feed [Customer.new, Customer.new] }

    it_should_behave_like "any SData feed"

    it "should contain two entries" do
      feed_xml.xpath('xmlns:entry').should have(2).entries
    end

    it "should not contain eny diagnoses" do
      feed_xml.should_not have_xpath("sdata:diagnosis")
    end
  end

  context "when there is no entries" do
    subject { @feed = build_feed [] }

    it_should_behave_like "any SData feed"

    it "should have no entries" do
      feed_xml.should_not ahve_xpath('xmlns:entry')
    end

    it "should have no diagnoses" do
      feed_xml.should_not have_xpath("sdata:diagnosis")
    end
  end

  context "when entry payload is erroneous" do
    class CustomerWithErroneousPayload < Customer
      def resource_header_attributes
        raise "Something went wrong"
      end
    end

    before { @feed = build_feed [Customer.new, CustomerWithErroneousPayload.new] }

    it_should_behave_like "any SData feed"

    it "should contain all scope elements as entries" do
      feed_xml.xpath('/xmlns:feed/xmlns:entry').should have(2).entries
    end

    describe "erroneous entry" do
      subject { feed_xml.xpath('/xmlns:feed/xmlns:entry').first }

      it "should contain SData diagnosis" do
        subject.should have_xpath('sdata:diagnosis')
      end

      describe "entry diagnosis" do
        subject { feed_xml.xpath('//xmlns:entry/sdata:diagnosis').first }

        it "should have 'error' severity" do
          subject.xpath('sdata:severity/text()').to_s.should == 'error'
        end

        it "should contain diagnosis type in sdata:sdataCode node" do
          subject.xpath('sdata:sdataCode/text()').to_s.should == 'ApplicationDiagnosi'
        end

        it "should contain actual exception message in sdata:message node" do
          subject.xpath('sdata:message/text()').to_s.should == "Exception while trying to construct payload map"
        end

        it "should include stacktrace" do
          subject.xpath('sdata:stackTrace/text()').to_s.should include('/collection_spec.rb')
        end
      end
    end

    describe "healthy entry" do
      subject { feed_xml.xpath('/xmlns:feed/xmlns:entry').second }

      it "should not contain SData diagnosis" do
        subject.should_not have_xpath('sdata:diagnosis')
      end

      it "should have non-empty id" do
        subject.xpath('xmlns:id/text()').to_s.should_not be_empty
      end

      it "should have non-empty content" do
        subject.xpath('xmlns:content/text()').to_s.should_not be_empty
      end

      it "should have SData payload" do
        subject.should have_xpath('sdata:payload')
      end
    end
  end

  context "when the whole entry is erroneous" do
    class ErroneousCustomer < Customer
      def id
        raise "Something went wrong"
      end
    end

    before { @feed = build_feed(ErroneousCustomer.new, Customer.new) }

    it_should_behave_like "any SData feed"

    it "should still include healthy entry" do
      feed_xml.xpath('/xmlns:feed/xmlns:entry').should have(1).entry
    end

    it "should include feed diagnosis into response" do
      feed_xml.xpath('/xmlns:feed/sdata:diagnosis').should have(1).diagnosis
    end
  end

  context "when both feed and entry are erroneous" do
    before { @feed = build_feed(ErroneousCustomer.new, CustomerWithErroneousPayload.new) }

    it_should_behave_like "any SData feed"

    it "should include entry diagnosis" do
      feed_xml.sould have_xpath('/xmlns:feed/xmlns:entry/sdata:diagnosis')
    end

    it "should include feed diagnosis" do
      feed_xml.sould have_xpath('/xmlns:feed/sdata:diagnosis')
    end
  end
end
