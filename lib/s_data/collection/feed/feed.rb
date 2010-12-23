# -*- coding: utf-8 -*-
module SData
  class Collection
    class Feed < Struct.new(:resource_class, :scope, :pagination, :links, :context)
      attr_accessor :atom_feed

      def initialize(*args)
        super(*args)
        build_atom_feed

        atom_feed.set_properties(category_term, collection_url, feed_options)
        atom_feed.populate_open_search(scope.resource_count, pagination)
        atom_feed.links << links
        atom_feed.assign_entries(scope)
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

      def category_term
        resource_class.name.demodulize.camelize(:lower).pluralize
      end

      def collection_url
        resource_class.collection_url(context)
      end

      def feed_options
        resource_class.sdata_options[:feed]
      end

      module AtomFeedExtensions
        def set_properties(category_term, collection_url, options)
          self.title = options[:title]
          self.updated = Time.now
          self.authors << Atom::Person.new(:name => options[:author])
          self.id = collection_url
          self.categories << Atom::Category.new(:scheme => 'http://schemas.sage.com/sdata/categories',
                                                :term   => category_term,
                                                :label  => category_term.underscore.humanize.titleize)
        end

        def assign_entries(scope)
          scope.resources.each do |resource|
            entry = SData::Collection::Entry.new(resource, context)
            unless entry.diagnosis?
              self.entries << entry
            else
              self[SData.config[:schemas]['sdata'], 'diagnosis'] << diagnosis
            end
          end
        end

        def populate_open_search(total_results, pagination)
          self[SData.config[:schemas]['opensearch'], 'totalResults'] << total_results
          self[SData.config[:schemas]['opensearch'], 'startIndex'] << pagination.one_based_start_index
          self[SData.config[:schemas]['opensearch'], 'itemsPerPage'] << pagination.records_to_return
        end
      end
    end
  end
end
