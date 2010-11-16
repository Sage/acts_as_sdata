module SData
  class Collection
    def to_xml
      build_feed
      feed.to_xml
    end

    protected

    def build_feed
      self.feed = SData::Collection::Feed.new(entries, feed_options) # the core code is in Feed#assign_entries
    end
  end
end
