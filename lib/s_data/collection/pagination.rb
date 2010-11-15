module SData
  class Collection
    class Pagination < Struct.new(:default_items_per_page, :maximum_items_per_page, :startIndex, :count)
      def records_to_return
        default_items_per_page = self.default_items_per_page || 10
        maximum_items_per_page = self.maximum_items_per_page || 100
        
        return default_items_per_page if count  <= 0
        
        items_per_page = [count, maximum_items_per_page].min
        items_per_page = default_items_per_page if (items_per_page <= 0)
        items_per_page
      end

      def one_based_start_index
        [startIndex, 1].max
      end

      def zero_based_start_index
        [(one_based_start_index - 1), 0].max
      end
    end
  end
end
