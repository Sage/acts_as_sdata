require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Collection::PaginationParams do
  describe "#count" do
    subject { @pagination_params.count }
    
    context "when :count is a valid number image" do
      before { @pagination_params = Factory.build :pagination_params, :params => { :count => '42' } }

      it "should correctly convert number image to number" do
        should == 42
      end
    end
    
    context "when :count is empty" do
      before { @pagination_params = Factory.build :pagination_params, :params => { :count => "" } }

      it "should return default value" do
        should == 10
      end
    end

    context "when :count is absent" do
      before { @pagination_params = Factory.build :pagination_params, :params => {} }

      it "should return default value" do
        should == 10
      end
    end

    context "when :count is an invalid number " do
      before { @pagination_params = Factory.build :pagination_params, :params => { :count => "forty-two" } }

      it "should return default value" do
        should == 10
      end
    end

    context "when :default_items_per_page feed option is provided" do
      before { @pagination_params = Factory.build :pagination_params, :params => {}, :feed_options => { :default_items_per_page => 86400 } }

      it "should return given value as a default one" do
        should == 86400
      end
    end
  end

  describe "#items_per_page" do
    subject { @pagination_params.items_per_page }

    context "when :count is a valid positive number" do
      before { @pagination_params = Factory.build :pagination_params, :params => { :count => "5" } }

      it { should == 5 }
    end
    
    context "when :count is zero" do
      before { @pagination_params = Factory.build :pagination_params, :params => { :count => "0" } }

      it "should return zero too" do
        should == 0
      end
    end

    context "when :count is negative" do
      before { @pagination_params = Factory.build :pagination_params, :params => { :count => "-5" } }

      it "should return default_items_per_page" do
        should == 10
      end
    end

    context "when :count is too big" do
      before { @pagination_params = Factory.build :pagination_params, :params => { :count => "100500" } }

      it "should return maximum_items_per_page" do
        should == 100
      end
    end
  end

  describe "#start_index" do
    subject { @pagination_params.start_index }
    
    context "when :startIndex is positive" do
      before { @pagination_params = Factory.build :pagination_params, :params => { :startIndex => "5" } }
      
      it { should == 5 }
    end

    context "when :startIndex is absent" do
      before { @pagination_params = Factory.build :pagination_params, :params => {} }
      
      it { should == 1 }
    end

    context "when :startIndex is zero" do
      before { @pagination_params = Factory.build :pagination_params, :params => { :startIndex => "0" } }

      it { should == 1 }
    end

    context "when :startIndex is negative" do
      before { @pagination_params = Factory.build :pagination_params, :params => { :startIndex => "-5" } }

      it { should == 1 }
    end

    context "when :startIndex is not a number" do
      before { @pagination_params = Factory.build :pagination_params, :params => { :startIndex => "fifty" } }

      it { should == 1 }
    end
  end
end
