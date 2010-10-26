# -*- coding: utf-8 -*-
module SData
  class Collection
    class Feed < Atom::Feed
      attr_accessor :resource_url, :options
      
      def initialize(entries, resource_url, feed_options)
        super()
        self.options = feed_options
        set_properties(resource_url, feed_options)
        assign_entries(entries)
        populate_open_search
        #build_feed_links
      end

      protected

      def set_properties(resource_url, options)
        self.title = options[:title]
        self.updated = Time.now
        self.authors << Atom::Person.new(:name => options[:author])
        self.id = resource_url
        self.categories << Atom::Category.new(:scheme => 'http://schemas.sage.com/sdata/categories',
                                              :term   => self.category_term,
                                              :label  => self.category_term.underscore.humanize.titleize)
      end

      def assign_entries(entries)
        entries.each do |entry|
          begin
            add_entry(entry)
          rescue Exception => exception
            add_error(exception)
          end
        end
      end

      def add_entry(entry)
        self.entries << entry.to_atom(params)
      end    

      def add_error(exception)
        self[SData.config[:schemas]['sdata'], 'diagnosis'] << compose_diagnosis(exception)
      end

      def compose_diagnosis(exception)
        ApplicationDiagnosis.new(:exception => exception).to_xml(:feed)
      end

      def build_feed_links
        self.links << Atom::Link.new(
                                     :rel => 'self',
                                     :href => (resource_url + "?#{request.params.to_param}".chomp('?')),
                                     :type => 'application/atom+xml; type=feed',
                                     :title => 'Refresh')
        if (records_to_return > 0) && (@total_results > records_to_return)
          self.links << Atom::Link.new(
                                       :rel => 'first',
                                       :href => (resource_url + "?#{request.params.merge(:startIndex => '1').to_param}"),
                                       :type => 'application/atom+xml; type=feed',
                                       :title => 'First Page')
          self.links << Atom::Link.new(
                                       :rel => 'last',
                                       :href => (resource_url + "?#{request.params.merge(:startIndex => [1,(@last=(((@total_results-zero_based_start_index - 1) / records_to_return * records_to_return) + zero_based_start_index + 1))].max).to_param}"),
                                       :type => 'application/atom+xml; type=feed',
                                       :title => 'Last Page')
          if (one_based_start_index+records_to_return) <= @total_results
            self.links << Atom::Link.new(
                                         :rel => 'next',
                                         :href => (resource_url + "?#{request.params.merge(:startIndex => [1,[@last, (one_based_start_index+records_to_return)].min].max.to_s).to_param}"),
                                         :type => 'application/atom+xml; type=feed',
                                         :title => 'Next Page')
          end
          if (one_based_start_index > 1)
            self.links << Atom::Link.new(
                                         :rel => 'previous',
                                         :href => (resource_url + "?#{request.params.merge(:startIndex => [1,[@last, (one_based_start_index-records_to_return)].min].max.to_s).to_param}"),
                                         :type => 'application/atom+xml; type=feed',
                                         :title => 'Previous Page')
          end
        end
      end

      def params
        { :count => 10 }
      end
      
        

      # pagination as a separate class?
      def records_to_return
        default_items_per_page = options[:default_items_per_page] || 10
        maximum_items_per_page = options[:maximum_items_per_page] || 100
        #check whether the count param is castable into integer
        return default_items_per_page if params[:count].blank? or (params[:count].to_i.to_s != params[:count])
        items_per_page = [params[:count].to_i, maximum_items_per_page].min
        items_per_page = default_items_per_page if (items_per_page < 0)
        items_per_page
      end

      def one_based_start_index
        [(params[:startIndex].to_i), 1].max
      end

      def zero_based_start_index
        [(one_based_start_index - 1), 0].max
      end

      def populate_open_search
        self[SData.config[:schemas]['opensearch'], 'totalResults'] << @total_results
        self[SData.config[:schemas]['opensearch'], 'startIndex'] << one_based_start_index
        self[SData.config[:schemas]['opensearch'], 'itemsPerPage'] << records_to_return
      end

      def category_term
        'customers'
        # self.sdata_resource.name.demodulize.camelize(:lower).pluralize
      end
    end
  end
end
