module SData
  module Application
    class Context < Struct.new(:params, :query_params)
      def sync?
        params[:sync].to_s == 'true'
      end

      def dataset
        params[:dataset]
      end

      def selected
        params[:select].to_s.split(',')
      end

      def included
        params[:include].to_s.split(',')
      end

      def maximum_precedence
        params[:precedence].blank? ? params[:precedence].to_i : 100
      end

      def expand?
        (sync || included.include?('$children')) ? :all_children : :immediate_children
      end

      def linked?
        params[:condition] == "$linked"
      end
    end
  end
end
