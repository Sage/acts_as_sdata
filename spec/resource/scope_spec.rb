require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Resource::Scope do
  shared_examples_for "a scoped resource" do
    it { should respond_to(:with_pagination) }
  end
  
  context "given an adequate Resource::Base" do
    before :all do
      remove_constants :Customer
      class Customer < SData::Resource::Base; end
    end

    describe "scoped resource" do
      subject { Customer.sdata_scope_for_context }

      it_should_behave_like "a scoped resource"

      describe "deeper scoped resource" do
        subject do
          Customer.with_sdata_scope do |scope|
            scope.with_pagination do |scope|
              return scope
            end
          end
        end

        it_should_behave_like "a scoped resource"
      end
    end
  end

  describe "#all" do
    context "given a scoped resource" do
      
    end

  end
end
