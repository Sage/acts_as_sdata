module SData
  class Collection
    class PaginationParams < Struct.new(:feed_options, :params)
      def initialize(*args)
        super(*args)
      end
      
      def records_to_return
        return default_items_per_page if count.nil?
        
        items_per_page = [count, maximum_items_per_page].min
        items_per_page = default_items_per_page if (items_per_page < 0)
        items_per_page
      end

      def count
        @count ||= (params[:count].to_i.to_s == params[:count]) ? params[:count].to_i : default_items_per_page
      end

      def default_items_per_page
        feed_options[:default_items_per_page] || 10
      end

      def maximum_items_per_page
        feed_options[:maximum_items_per_page] || 100
      end
    end
  end
end
