require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Collection::Pagination do
  describe "#single_page?" do
    context "when entry count is greater than items per page" do
      it { should be_false }
    end

    context "when entry count is lesser than items per page" do
      it { should be_true }
    end
  end
  
  describe "#first_page?" do
    context "when start index belongs to first page" do
      it { should be_true }
    end

    context "when start index is out of first page bounds" do
      it { should be_false }
    end
  end

  describe "#last_page?" do
    context "when start index belongs to last page" do
      it { should be_true }
    end

    context "when start index is out of last page bounds" do
      it { should be_false }
    end
  end

  describe "#current_page_start_index" do
    it "should return one-based current start index" do
    end
  end

  describe "#first_page_start_index" do
    it { should == 1 }
  end

  describe "#last_page_start_index" do
    context "when entry count is a multiple of items per page" do
    end

    context "when entry count is not a multiple of items per page" do
    end
  end

  describe "#previous_page_start_index" do
    context "when current start index is a multiple of items per page" do
    end

    context "when current start index is not a multiple of items per page" do
    end
  end

  describe "#next_page_start_index" do
    context "when current start index is multiple of items per page" do
    end

    context "when current start index is not a multiple of items per page" do
    end
  end
end
