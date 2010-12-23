# -*- coding: utf-8 -*-
module SData
  class Collection
    class Feed < Struct.new(:resource_class, :scope, :pagination, :links, :context)
      attr_accessor :atom_feed

      def initialize(*args)
        super(*args)
        build_atom_feed

        atom_feed.set_properties(resource_class, resource_class.collection_url(context), resource_class.sdata_options[:feed])
        atom_feed.populate_open_search(scope.resource_count, pagination)
        atom_feed.add_links(links)
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

        def add_links(links)
          self.links << links.atom_links
        end

        def populate_open_search(total_results, pagination)
          self[SData.config[:schemas]['opensearch'], 'totalResults'] << total_results
          self[SData.config[:schemas]['opensearch'], 'startIndex'] << pagination.one_based_start_index
          self[SData.config[:schemas]['opensearch'], 'itemsPerPage'] << pagination.records_to_return
        end

        # grrr
        def category_term
          resource_class.name.demodulize.camelize(:lower).pluralize
        end
      end
    end
  end
end
