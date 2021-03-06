module SData
  module Application
    class Context < Struct.new(:params, :query_params)
      def initialize(*args)
        super(*args)
        self.query_params ||= {}
        query_params.symbolize_keys!
      end
      
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
        params[:precedence].blank? ? 100 : params[:precedence].to_i
      end

      def expand?
        (sync? || included.include?('$children')) ? :all_children : :immediate_children
      end

      def linked?
        params[:condition] == "$linked"
      end
    end
  end
end
