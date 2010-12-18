# -*- coding: utf-8 -*-
module SData
  class Collection
    class Feed < Struct.new(:resource_class, :params, :feed_options, :scope, :pagination, :query_params)
      def initialize(*args)
        super(*args)

        build_resource_url
        build_atom_feed

        atom_feed.set_properties(resource_class, resource_url, feed_options)
        
        atom_feed.populate_open_search(scope, pagination)
        atom_feed.build_feed_links(params, query_params, scope, pagination)
      end

      def to_xml
        atom_feed.assign_entries(scope.entries, params)
        atom_feed.to_xml
      end

      protected

      def dataset
        params[:dataset]
      end      

      def build_resource_url
        self.resource_url = resource_class.sdata_resource_kind_url(dataset)
      end

      def build_atom_feed
        self.atom_feed = Atom::Feed.new.tap do |atom_feed|
          class << atom_feed
            include AtomFeedExtensions
          end
        end
      end

      module AtomFeedExtensions
        attr_accessor :resource_class
        
        def set_properties(resource_class, resource_url, options)
          self.resource_class = resource_class
          
          self.title = options[:title]
          self.updated = Time.now
          self.authors << Atom::Person.new(:name => options[:author])
          self.id = resource_url
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

        def build_feed_links(params, query_params, scope, pagination)
          dataset = params[:dataset]
          resource_url = resource_class.sdata_resource_kind_url(dataset)
          total_results = scope.entry_count
          records_to_return = pagination.records_to_return
          one_based_start_index = pagination.one_based_start_index
          zero_based_start_index = pagination.zero_based_start_index
          
          self.links << Atom::Link.new(
                                       :rel => 'self',
                                       :href => (resource_url + "?#{query_params.to_param}".chomp('?')),
                                       :type => 'application/atom+xml; type=feed',
                                       :title => 'Refresh')
          if (records_to_return > 0) && (total_results > records_to_return)
            self.links << Atom::Link.new(
                                         :rel => 'first',
                                         :href => (resource_url + "?#{query_params.merge(:startIndex => '1').to_param}"),
                                         :type => 'application/atom+xml; type=feed',
                                         :title => 'First Page')
            self.links << Atom::Link.new(
                                         :rel => 'last',
                                         :href => (resource_url + "?#{query_params.merge(:startIndex => [1,(@last=(((total_results-zero_based_start_index - 1) / records_to_return * records_to_return) + zero_based_start_index + 1))].max).to_param}"),
                                         :type => 'application/atom+xml; type=feed',
                                         :title => 'Last Page')
            if (one_based_start_index+records_to_return) <= total_results
              self.links << Atom::Link.new(
                                           :rel => 'next',
                                           :href => (resource_url + "?#{query_params.merge(:startIndex => [1,[@last, (one_based_start_index+records_to_return)].min].max.to_s).to_param}"),
                                           :type => 'application/atom+xml; type=feed',
                                           :title => 'Next Page')
            end
            if (one_based_start_index > 1)
              self.links << Atom::Link.new(
                                           :rel => 'previous',
                                           :href => (resource_url + "?#{query_params.merge(:startIndex => [1,[@last, (one_based_start_index-records_to_return)].min].max.to_s).to_param}"),
                                           :type => 'application/atom+xml; type=feed',
                                           :title => 'Previous Page')
            end
          end
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
      attr_accessor :resource_url
    end
  end
end
