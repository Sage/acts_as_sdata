module SData
  class Collection
    class Pagination < Struct.new :pagination_params, :entry_count
      delegate :items_per_page, :start_index, :to => :pagination_params
      
      def single_page?
        page_count <= 1
      end

      def first_page?
        current_page == 1
      end

      def last_page?
        current_page == page_count
      end

      def first_page_start_index
        1
      end

      def last_page_start_index
        start_index_of_page(page_count)
      end

      def previous_page_start_index
        start_index_of_page(current_page - 1)
      end

      def current_page_start_index
        start_index_of_page(current_page)
      end

      def next_page_start_index
        start_index_of_page(current_page + 1)
      end

      def current_page
        (start_index - 1) / items_per_page + 1
      end

      def page_count
        entry_count % items_per_page == 0 ?
          entry_count / items_per_page :
          entry_count / items_per_page + 1
      end

      protected

      def start_index_of_page(page)
        items_per_page * (page - 1) + 1
      end
    end
  end
end
