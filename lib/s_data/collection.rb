module SData
  class Collection
    def initialize(collection_scope, feed_options)
      self.feed_options = feed_options
      self.collection_scope = collection_scope
    end

    def to_xml
      build_feed
      feed.to_xml
    end

    protected

    def build_feed
      begin
        entries = collection_scope.entries
        self.feed = SData::Collection::Feed.new(entries, sdata_options[:feed])
      rescue
        self.feed = SData::FeedDiagnosis.new(entries, sdata_options[:feed])
      end
    end
  end
end
