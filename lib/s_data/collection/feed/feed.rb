# -*- coding: utf-8 -*-
module SData
  class Collection
    class Feed < Struct.new(:resource_class, :feed_options, :entries, :collection_url, :pagination, :links)
      attr_accessor :atom_feed
      
      def initialize(*args)
        super(*args)
        build_atom_feed

        atom_feed.set_properties(resource_class, collection_url, feed_options)
        atom_feed.populate_open_search(entries.count, pagination)
        atom_feed.add_links(links)
        atom_feed.assign_entries(entries)
      end

      def to_xml
        atom_feed.to_xml
      end

      protected

      def build_atom_feed
        self.atom_feed = Atom::Feed.new.tap do |atom_feed|
          class << atom_feed
            include AtomFeedExtensions
          end
        end
      end

      module AtomFeedExtensions
        attr_accessor :resource_class
        
        def set_properties(resource_class, collection_url, options)
          self.resource_class = resource_class
          self.title = options[:title]
          self.updated = Time.now
          self.authors << Atom::Person.new(:name => options[:author])
          self.id = collection_url
          self.categories << Atom::Category.new(:scheme => 'http://schemas.sage.com/sdata/categories',
                                                :term   => category_term,
                                                :label  => category_term.underscore.humanize.titleize)
        end

        def assign_entries(entries)
          entries.each do |entry|
            self.entries << entry
          end

          entries.diagnoses.each do |diagnosis|
            self[SData.config[:schemas]['sdata'], 'diagnosis'] << diagnosis
          end          
        end

        def add_links(links)
          self.links << links.atom_links
        end

        def populate_open_search(total_results, pagination)
          self[SData.config[:schemas]['opensearch'], 'totalResults'] << total_results
          self[SData.config[:schemas]['opensearch'], 'startIndex'] << pagination.one_based_start_index
          self[SData.config[:schemas]['opensearch'], 'itemsPerPage'] << pagination.records_to_return
        end

        def category_term
          resource_class.name.demodulize.camelize(:lower).pluralize
        end
      end
    end
  end
end
