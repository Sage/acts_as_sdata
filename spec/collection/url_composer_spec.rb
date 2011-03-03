require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Collection::Links::UrlComposer do
  describe "#compose_link_url" do
    before { subject.base_url = "http://billingboss.com/pancakes" }
    
    context "when startIndex is 1" do
      it "should not be added to URL" do
        subject.compose_link_url(1).should == "http://billingboss.com/pancakes"
      end
    end
    
    context "when startIndex is not 1" do
      it "should be added to URL" do
        subject.compose_link_url(6).should == "http://billingboss.com/pancakes?startIndex=6"
      end
    end
    
    context "when :startIndex param is also provided in URL" do
      before { subject.query_params = { :startIndex => 6 } }

      it "should be overriden by methor parameter" do
        subject.compose_link_url(2).should == "http://billingboss.com/pancakes?startIndex=2"
      end
    end
    
    context "when :count is provided default" do
      context "when provided :count param it equals to default value" do
        before { subject.query_params = { :count => 10 } }

        it "should not be added to URL" do
          subject.compose_link_url(6).should == "http://billingboss.com/pancakes?startIndex=6"
        end
      end

      context "when provided :count param it does not equal to default value" do
        before { subject.query_params = { :count => 5 } }
        
        it "should be added to URL" do
          subject.compose_link_url(6).should == "http://billingboss.com/pancakes?count=5&startIndex=6"
        end
      end
    end
    
    context "when there are additional parameters" do
      before { subject.query_params = { :w00t => '42' } }
      
      it "should add those parameters in a row" do
        subject.compose_link_url(6).should == "http://billingboss.com/pancakes?startIndex=6&w00t=42"
      end
    end
  end
end
