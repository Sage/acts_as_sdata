require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Collection::PaginationParams do
  describe "#count" do
    context "when :count is a valid number image" do
      subject { Factory.build :pagination_params, :params => { :count => '42' } }

      it "should correctly convert number image to number" do
        subject.count.should == 42
      end
    end
    
    context "when :count is empty" do
      subject { Factory.build :pagination_params, :params => { :count => "" } }

      it "should return default value" do
        subject.count.should == 10
      end
    end

    context "when :count is absent" do
      subject { Factory.build :pagination_params, :params => {} }

      it "should return default value" do
        subject.count.should == 10
      end
    end

    context "when :count is an invalid number " do
      subject { Factory.build :pagination_params, :params => { :count => "forty-two" } }

      it "should return default value" do
        subject.count.should == 10
      end
    end

    context "when :default_items_per_page feed option is provided" do
      subject { Factory.build :pagination_params, :params => {}, :feed_options => { :default_items_per_page => 86400 } }

      it "should return given value as a default one" do
        subject.count.should == 86400
      end
    end
  end
  
  describe "#records_to_return" do
    context "when count is zero" do
      subject { Factory.build :pagination_params, :params => { :count => "0" } }

      it "should return zero too" do
        subject.records_to_return.should == 0
      end
    end

    context "when count is negative" do
      subject { Factory.build :pagination_params, :params => { :count => "-5" } }

      it "should return default_items_per_page" do
        subject.records_to_return.should == 10
      end
    end

    context "when :count is too big" do
      subject { Factory.build :pagination_params, :params => { :count => "100500" } }

      it "should return maximum_items_per_page" do
        subject.records_to_return.should == 100
      end
    end
  end
end
