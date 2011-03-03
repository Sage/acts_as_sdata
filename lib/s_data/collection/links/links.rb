module SData
  class Collection
    class Links < Struct.new(:url_composer, :pagination)
      def atom_links
        [].tap do |atom_links|
          atom_links << compose_link('self', 'Refresh', pagination.current_page_start_index)
          unless pagination.single_page?
            atom_links << compose_link('first', 'First Page', pagination.first_page_start_index)
            atom_links << compose_link('last', 'Last Page', pagination.last_page_start_index)
            atom_links << compose_link('previous', 'Previous Page', pagination.previous_page_start_index) unless pagination.first_page?
            atom_links << compose_link('next', 'Next Page', pagination.next_page_start_index) unless pagination.last_page?
          end
        end
      end

      protected

      def compose_link(rel, title,  start_index)
        Atom::Link.new :rel => rel,
                       :href => url_composer.compose_link_url(start_index),
                       :type => 'application/atom+xml; type=feed',
                       :title => title
      end
    end
  end
end
