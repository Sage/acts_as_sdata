require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Collection::Feed do
  def build_feed(*entries)
   feed_options = { :author => 'Test Author',
            :path => '/test_resource',
            :title => 'List of Test Items',
            :default_items_per_page => 10,
            :maximum_items_per_page => 100 }

    SData::Collection::Feed.new(Customer, '-', feed_options, entries)
  end

  def feed_xml
    parse_xml(@feed.to_xml)
  end

  shared_examples_for "any SData feed" do
    it "should be an Atom Feed" do
      feed_xml.should have_xpath("/xmlns:feed[namespace-uri()='http://www.w3.org/2005/Atom']")
    end

    describe "main feed properties" do
      subject { feed_xml.xpath('/xmlns:feed') }

      it "should set author according to given feed options" do
        subject.xpath('xmlns:author/xmlns:name/text()').should == 'Test Author'
      end

      it "should set title according to given feed options" do
        subject.xpath('xmlns:title/text()').should == 'List of Test Items'
      end
    end

    it "should include a category" do
      feed_xml.should have_xpath('/xmlns:feed/xmlns:category')
    end

    describe "feed category" do
      subject { feed_xml.xpath('/xmlns:feed/xmlns:category') }

      it "should have a term accoring to given SData resource" do
        subject.xpath('@term').should == 'customers'
      end

      it "should have a label according to given SData resource" do
        subject.xpath('@label').should == 'Customers'
      end

      it "should have an SData scheme" do
        subject.xpath('@scheme').should == "http://schemas.sage.com/sdata/categories"
      end
    end
  end

  context "when all entries are healthy" do
    before { @feed = build_feed Factory.build(:healthy_entry), Factory.build(:healthy_entry) }

    it_should_behave_like "any SData feed"

    it "should contain two entries" do
      feed_xml.xpath('/xmlns:feed/xmlns:entry').should have(2).entries
    end

    it "should not contain eny diagnoses" do
      feed_xml.should_not have_xpath("//sdata:diagnosis")
    end
  end

  context "when there is no entries" do
    before { @feed = build_feed }

    it_should_behave_like "any SData feed"

    it "should have no entries" do
      feed_xml.should_not have_xpath('xmlns:entry')
    end

    it "should have no diagnoses" do
      feed_xml.should_not have_xpath("sdata:diagnosis")
    end
  end

  context "when entry payload is erroneous" do
    before { @feed = build_feed Factory.build(:healthy_entry), Factory.build(:entry_with_erroneous_payload) }

    it_should_behave_like "any SData feed"

    it "should contain all scope elements as entries" do
      feed_xml.xpath('/xmlns:feed/xmlns:entry').should have(2).entries
    end

    describe "erroneous entry" do
      subject { feed_xml.xpath('/xmlns:feed/xmlns:entry').to_a.second }

      it "should contain SData diagnosis" do
        subject.should have_xpath('sdata:diagnosis')
      end

      describe "entry diagnosis" do
        subject { feed_xml.xpath('//xmlns:entry/sdata:diagnosis').first }

        it "should have 'error' severity" do
          subject.xpath('sdata:severity/text()').should == 'error'
        end

        it "should contain diagnosis type in sdata:sdataCode node" do
          subject.xpath('sdata:sdataCode/text()').should == 'ApplicationDiagnosis'
        end

        it "should contain actual exception message in sdata:message node" do
          subject.xpath('sdata:message/text()').should == "Something went wrong"
        end

        it "should include stacktrace" do
          subject.xpath('sdata:stackTrace/text()').to_s.should include('/feed_spec.rb')
        end
      end
    end

    describe "healthy entry" do
      subject { feed_xml.xpath('/xmlns:feed/xmlns:entry').first }

      it "should not contain SData diagnosis" do
        subject.should_not have_xpath('sdata:diagnosis')
      end

      it "should have non-empty id" do
        subject.xpath('xmlns:id/text()').should_not be_empty
      end

      it "should have non-empty content" do
        subject.xpath('xmlns:content/text()').should_not be_empty
      end

      it "should have SData payload" do
        subject.should have_xpath('sdata:payload')
      end
    end
  end

  context "when the whole entry is erroneous" do
    before { @feed = build_feed(Factory.build(:completely_erroneous_entry), Factory.build(:healthy_entry)) }

    it_should_behave_like "any SData feed"

    it "should still include healthy entry" do
      feed_xml.xpath('/xmlns:feed/xmlns:entry').should have(1).entry
    end

    it "should include feed diagnosis into response" do
      feed_xml.xpath('/xmlns:feed/sdata:diagnosis').should have(1).diagnosis
    end
  end

  context "when both feed and entry are erroneous" do
    before { @feed = build_feed(Factory.build(:completely_erroneous_entry), Factory.build(:entry_with_erroneous_payload)) }

    it_should_behave_like "any SData feed"

    it "should include entry diagnosis" do
      feed_xml.should have_xpath('/xmlns:feed/xmlns:entry/sdata:diagnosis')
    end

    it "should include feed diagnosis" do
      feed_xml.should have_xpath('/xmlns:feed/sdata:diagnosis')
    end
  end
end
