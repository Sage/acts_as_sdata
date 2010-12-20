module SData
  class Collection
    class Links < Struct.new(:base_url, :pagination, :query_params)
      def atom_links
        total_results = pagination.count
        records_to_return = pagination.records_to_return
        one_based_start_index = pagination.one_based_start_index
        zero_based_start_index = pagination.zero_based_start_index

        atom_links= Atom::Link.new(
                                     :rel => 'self',
                                     :href => (base_url + "?#{query_params.to_param}".chomp('?')),
                                     :type => 'application/atom+xml; type=feed',
                                     :title => 'Refresh')
        if (records_to_return > 0) && (total_results > records_to_return)
          atom_links << Atom::Link.new(
                                       :rel => 'first',
                                       :href => (base_url + "?#{query_params.merge(:startIndex => '1').to_param}"),
                                       :type => 'application/atom+xml; type=feed',
                                       :title => 'First Page')
          atom_links << Atom::Link.new(
                                       :rel => 'last',
                                       :href => (base_url + "?#{query_params.merge(:startIndex => [1,(@last=(((total_results-zero_based_start_index - 1) / records_to_return * records_to_return) + zero_based_start_index + 1))].max).to_param}"),
                                       :type => 'application/atom+xml; type=feed',
                                       :title => 'Last Page')
          if (one_based_start_index+records_to_return) <= total_results
            atom_links << Atom::Link.new(
                                         :rel => 'next',
                                         :href => (base_url + "?#{query_params.merge(:startIndex => [1,[@last, (one_based_start_index+records_to_return)].min].max.to_s).to_param}"),
                                         :type => 'application/atom+xml; type=feed',
                                         :title => 'Next Page')
          end
          if (one_based_start_index > 1)
            atom_links << Atom::Link.new(
                                         :rel => 'previous',
                                         :href => (base_url + "?#{query_params.merge(:startIndex => [1,[@last, (one_based_start_index-records_to_return)].min].max.to_s).to_param}"),
                                         :type => 'application/atom+xml; type=feed',
                                         :title => 'Previous Page')
          end

          atom_links
        end
      end
    end
  end
end
