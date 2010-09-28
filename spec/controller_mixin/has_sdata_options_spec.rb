__DIR__ = File.dirname(__FILE__)
require File.join(__DIR__, '..', 'spec_helper')

include SData

describe Resource::Base, ".has_sdata_options" do
  describe "given an sdata resource" do
    before :all do
      Base = Class.new Resource::Base
    end

    before :each do
      @options = { :model => Class.new }
      Base.has_sdataoptions @options
    end

    it "should make passed options available for class" do
      Base.sdata_options.should == @options
    end

    it "should make passed options available for instances" do
      Base.new.sdata_options.should == @options
    end
  end
end
