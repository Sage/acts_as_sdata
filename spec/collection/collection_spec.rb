describe SData::Collection do
  context "when #collection_entries fails" do
    it "should be still atom feed"
    it "should include feed diagnosis"
    it "should still contain healthy entries"

    context "when some entries are erroneous too" do
      it "should contain nested entry diagnoses"
    end
  end
end
