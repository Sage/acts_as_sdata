require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Resource::Base, "#scoped" do
  context "when there is no scoping" do
    subject { SomeResource }
    
    it "should have no additional conditions" do
      SomeResource.combined_scoping_conditions.should == {}
    end
  end

  context "when there is one scope" do
    subject { SomeResource.scoped(:conditions => { :field => 'value' }) }

    it "should have conditions of an applied scope" do
      SomeResource.combined_scoping_conditions.should == { :conditions => { :field => 'value' }  }
    end
  end

  context "when there are more than one consequtively applied scopes" do
    subject { SomeResource.scoped(:conditions => { :field => 'value' }).scoped(:limitt => 10) }

    it "should have conditions merged from from all applied scopes" do
      SomeResource.combined_scoping_conditions.should == { :conditions => { :field => 'value' }, :limit => 10 }
    end
  end
end
