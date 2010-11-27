require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe SData::Collection::Scope do
  before :all do
    remove_constants :SomeResource, :BaseModel

    BaseModel = Class.new(ActiveRecord::Base)
    
    class SomeResource < SData::Resource::Base
      self.baze_class = BaseModel

      define_payload_map :born_at => { :baze_field => :born_at }
    end
  end

  def set_collection_scope(params)
    pagination = Factory.build(:pagination)
    @collection_scope = SData::Collection::Scope.new(SomeResource, params, pagination)
  end

  def scope_conditions
    @collection_scope.scope.scope.send(:scoped_methods)
  end

  describe "#with_predicate" do
    context "when argument is nil" do
      it "should not raise a error" do
        lambda { SomeResource.with_predicate(nil) {} }.should_not raise_error
      end
    end
  end

  

  context "when model is non-linked" do
    context "when params contain where clause" do
      before { set_collection_scope 'where bornAt gt 1900' => nil }

      it "should apply to SData::Predicate for conditions" do
        scope_conditions.should == [{ :conditions => ["\"born_at\" > ?", '1900'] }]
      end

      context "when condition contain 'ne' relation" do
        before { set_collection_scope 'where bornAt gt 1900' => nil }

        it "should parse it correctly" do
          scope_conditions.should == { :conditions => ["\"born_at\" <> ?", '1900'] }
        end
      end
    end

    context "when params do not contain neither :predicate key nor where clause" do
      before { set_collection_scope({}) }

      it "should return all entity records" do
        scope_conditions.should == []
      end
    end
  end

  context "when model is linked" do
    context "being configured without user scoping" do
      before :all do
        SomeResource.class_eval do
          has_sdata_options :link => :simply_guid
        end
      end

      context "when params contain :condition key and where clause" do
        before { set_collection_scope 'where born_at gt 1900' => nil, :condition => '$linked' }

        it "should apply to SData::Predicate for conditions and append requirement for simply guid" do
          # BaseModel.should_receive(:find_with_deleted).with(:all, {:conditions => ['"born_at" > ? and id IN (SELECT bb_model_id FROM sd_uuids WHERE bb_model_type = \'BaseModel\' and sd_class = \'SomeResource\')', '1900']}
        end
      end

      context "when params contain :condition key but does not contain where clause" do
        before { set_collection_scope :condition => '$linked' }

        it "should return all entity records with simply guid" do
          # BaseModel.should_receive(:find_with_deleted).with(:all, {:conditions => ['id IN (SELECT bb_model_id FROM sd_uuids WHERE bb_model_type = \'BaseModel\' and sd_class = \'SomeResource\')']}).and_return([@returned_entries])
        end
      end
    end
  end

  context "when configured with scoping" do
    before :all do
      SomeResource.class_eval do
        has_sdata_options :link => :simply_guid,
                          :scoping => ["created_by_id = ?"]
      end
    end

    context "with no other params" do
      before { set_collection_scope {} }

      it "should return all entity records created_by scope" do
        scope_conditions.should == { :conditions => ['created_by_id = ?', "#{@user.id}"] }
      end
    end

    context "with condition and where clause" do
      before  { set_collection_scope 'where born_at gt 1900' => nil, :condition => '$linked' }

      it "should return all entity records with created_by, predicate, and link scope" do
        # BaseModel.should_receive(:find_with_deleted).with(:all, {:conditions => ['"born_at" > ? and created_by_id = ? and id IN (SELECT bb_model_id FROM sd_uuids WHERE bb_model_type = \'BaseModel\' and sd_class = \'SomeResource\')', '1900', @user.id.to_s]}).and_return([@returned_entries])
      end
    end
  end
end
