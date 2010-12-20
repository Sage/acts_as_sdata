# -*- coding: utf-8 -*-
module SData
  class Collection
    class Feed < Struct.new(:resource_class, :feed_options, :scope, :collection_url, :pagination, :links)
      def initialize(*args)
        super(*args)
        build_atom_feed
      end

      def to_xml(params)
        atom_feed.set_properties(resource_class, collection_url, feed_options)
        atom_feed.populate_open_search(scope, pagination)
        atom_feed.add_links(links)
        atom_feed.assign_entries(scope.entries, params)
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

        def assign_entries(entries, params)
          entries.each do |entry|
            begin
              add_entry(entry, params)
            rescue Exception => exception
              add_error(exception)
            end
          end
        end

        def add_entry(entry, params)
          self.entries << entry.to_atom(params)
        end    

        def add_error(exception)
          self[SData.config[:schemas]['sdata'], 'diagnosis'] << compose_diagnosis(exception)
        end

        def compose_diagnosis(exception)
          ApplicationDiagnosis.new(:exception => exception).to_xml(:feed)
        end

        def add_links(links)
          self.links << links.atom_links
        end

        def populate_open_search(scope, pagination)
          self[SData.config[:schemas]['opensearch'], 'totalResults'] << scope.entry_count
          self[SData.config[:schemas]['opensearch'], 'startIndex'] << pagination.one_based_start_index
          self[SData.config[:schemas]['opensearch'], 'itemsPerPage'] << pagination.records_to_return
        end

        def category_term
          resource_class.name.demodulize.camelize(:lower).pluralize
        end
      end

      protected

      attr_accessor :atom_feed
    end
  end
end
