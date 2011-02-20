require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Collection::Pagination do
  subject { @pagination.single_page? }
  
  describe "#single_page?" do
    context "when entry count is greater than items per page" do
      before { @pagination = Factory.build(:pagination, :entry_count => 12) }
      
      it { should be_false }
    end

    context "when entry count is lesser than items per page" do
      before { @pagination = Factory.build(:pagination, :entry_count => 8) }
      
      it { should be_true }
    end
  end
  
  describe "#first_page?" do
    subject { @pagination.first_page? }
    
    context "when start index belongs to first page" do
      before do
        pagination_params = Factory.build :pagination_params, :params => { :start_index => 10 }
        @pagination = Factory.build :pagination, :pagination_params => pagination_params
      end
     
      it { should be_true }
    end

    context "when start index is out of first page bounds" do
      before do
        pagination_params = Factory.build :pagination_params, :params => { :start_index => 11 }
        @pagination = Factory.build :pagination, :pagination_params => pagination_params
      end
      
      it { should be_false }
    end
  end

  describe "#last_page?" do
    subject { @pagination.last_page? }
    
    context "when start index belongs to last page" do
      before do
        pagination_params = Factory.build :pagination_params, :params => { :start_index => 11 }
        @pagination = Factory.build :pagination, :pagination_params => pagination_params, :entry_count => 12
      end
     
      it { should be_true }
    end

    context "when start index is out of last page bounds" do
      before do
        pagination_params = Factory.build :pagination_params, :params => { :start_index => 9 }
        @pagination = Factory.build :pagination, :pagination_params => pagination_params, :entry_count => 12
      end
      
      it { should be_false }
    end
  end

  describe "#current_page_start_index" do
    subject { @pagination.current_page_start_index }

    context "when startIndex param is provided by user" do
      before do
        pagination_params = Factory.build :pagination_params, :params => { :start_index => 5 }
        @pagination = Factory.build :pagination, :pagination_params => pagination_params
      end

      it "should return one-based current start index" do
        should == 5
      end
    end

    context "when startIndex is not provided" do
      before do
        pagination_params = Factory.build :pagination_params, :params => {}
        @pagination = Factory.build :pagination, :pagination_params => pagination_params
      end

      it { should == 1 }
    end
  end

  describe "#first_page_start_index" do
    subject { Factory.build(:pagination).first_page_start_index }
    
    it "should always equal to 1" do
      should == 1
    end
  end

  describe "#last_page_start_index" do
    subject { @pagination.last_page_start_index }
    
    context "when entry count is a multiple of items per page" do
      before { @pagination = Factory.build :pagination, :entry_count => 20 }

      it "should return beginning of the last page" do
        should == 10
      end
    end

    context "when entry count is not a multiple of items per page" do
      before { @pagination = Factory.build :pagination, :entry_count => 23 }

      it "should leave aliquant remainder on the last page" do
        should == 20
      end
    end
  end

  context "when current start index is in the beginning of page" do
    before do
      pagination_params = Factory.build :pagination_params, :params => { :start_index => 21 }
      @pagination = Factory.build :pagination, :pagination_params => pagination_params, :entry_count => 44
    end

    describe "#previous_page_start_index" do
      subject { @pagination.previous_page_start_index }

      it "should return beginning of a previous page" do
        should == 11
      end
    end
    
    describe "#next_page_start_index" do
      subject { @pagination.next_page_start_index }

      it "should return beginning of a next page" do
        should == 31
      end
    end
  end

  context "when current start index is in the middle of page" do
    before do
      pagination_params = Factory.build :pagination_params, :params => { :start_index => 27 }
      @pagination = Factory.build :pagination, :pagination_params => pagination_params, :entry_count => 42
    end

    describe "#previous_page_start_index" do
      subject { @pagination.previous_page_start_index }

      it "should still return beginning of previous page" do
        should == 11
      end
    end
    
    describe "#next_page_start_index" do
      subject { @pagination.next_page_start_index }

      it "should still return beginning of next page" do
        should == 31
      end
    end
  end
end
