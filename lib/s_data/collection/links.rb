module SData
  class Collection
    class Links < Struct.new(:base_url, :pagination, :query_params)
      def atom_links
        total_results = pagination.count
        records_to_return = pagination.records_to_return
        one_based_start_index = pagination.one_based_start_index
        zero_based_start_index = pagination.zero_based_start_index

        atom_links = [Atom::Link.new(:rel => 'self',
                                     :href => current_url,
                                     :type => 'application/atom+xml; type=feed',
                                     :title => 'Refresh')]
        
        if (records_to_return > 0) && (total_results > records_to_return)
          atom_links << Atom::Link.new(
                                       :rel => 'first',
                                       :href => current_url_with_added_params(:startIndex => '1'),
                                       :type => 'application/atom+xml; type=feed',
                                       :title => 'First Page')
          atom_links << Atom::Link.new(
                                       :rel => 'last',
                                       :href => current_url_with_added_params(:startIndex => [1,(@last=(((total_results-zero_based_start_index - 1) / records_to_return * records_to_return) + zero_based_start_index + 1))].max),
                                       :type => 'application/atom+xml; type=feed',
                                       :title => 'Last Page')
          if (one_based_start_index+records_to_return) <= total_results
            atom_links << Atom::Link.new(
                                         :rel => 'next',
                                         :href => current_url_with_added_params(:startIndex => [1,[@last, (one_based_start_index+records_to_return)].min].max),
                                         :type => 'application/atom+xml; type=feed',
                                         :title => 'Next Page')
          end
          if (one_based_start_index > 1)
            atom_links << Atom::Link.new(
                                         :rel => 'previous',
                                         :href => current_url_with_added_params(:startIndex => [1,[@last, (one_based_start_index-records_to_return)].min].max),
                                         :type => 'application/atom+xml; type=feed',
                                         :title => 'Previous Page')
          end
        end
        
        atom_links
      end

      protected

      def current_url_with_added_params(added_params)
        compose_url(query_params.merge(added_params))
      end

      def current_url
        compose_url(query_params)
      end

      def compose_url(params)
        base_url + "?#{params.to_param}"
      end
    end
  end
end
