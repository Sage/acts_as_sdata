module SData
  class Collection
    class PaginationParams < Struct.new(:feed_options, :params)
      def initialize(*args)
        super(*args)
      end
      
      def items_per_page
        items_per_page = [count, maximum_items_per_page].min
        items_per_page = default_items_per_page if (items_per_page < 0)
        items_per_page
      end

      def default_items_per_page
        feed_options[:default_items_per_page] || 10
      end

      def maximum_items_per_page
        feed_options[:maximum_items_per_page] || 100
      end

      def count
        @count ||= extract_number_from_params(:count, default_items_per_page)
      end

      def start_index
        [extract_number_from_params(:startIndex, 1), 1].max
      end
      
      protected

      def extract_number_from_params(key, default_value)
        result = (params[key].to_i.to_s == params[key].to_s) ? params[key].to_i : default_value
      end
    end
  end
end
