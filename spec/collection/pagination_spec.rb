require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Collection::Pagination do
  describe "#records_to_return" do
    context "when :count is zero" do
      subject { SData::Collection::Pagination.new(10, nil, nil, 0).records_to_return }

      it "should return zero too" do
        subject.should == 0
      end
    end

    context "when :count is nil" do
      subject { SData::Collection::Pagination.new(10, nil, nil, nil).records_to_return }

      it "should return default value" do
        subject.should == 10
      end
    end
  end
end
