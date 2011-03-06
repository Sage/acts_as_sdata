__DIR__ = File.dirname(__FILE__)
require File.join(__DIR__, '..', 'spec_helper')

describe SData::Resource::Base, ".has_sdata_options" do
  describe "given an sdata resource" do
    before :all do
      Object.__send__ :remove_const, :SomeResource if defined?(SomeResource)
      class SomeResource < SData::Resource::Base; end
    end

    before :each do
      @options = { :model => Class.new }
      SomeResource.has_sdata_options @options
    end

    it "should make passed options available for class" do
      SomeResource.sdata_options.should == @options
    end

    it "should make passed options available for instances" do
      SomeResource.new.sdata_options.should == @options
    end
  end
end
