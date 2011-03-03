module SData
  class Collection
    class Links
      class UrlComposer < Struct.new(:base_url, :query_params)
        def compose_link_url(startIndex)
          params = (query_params || {}).dup
          params[:startIndex] = startIndex

          remove_default_values(params)
          query_string = compose_query_string(params)

          base_url + query_string
        end

        protected
        
        def remove_default_values(params)
          params.delete :startIndex if params[:startIndex] == 1
          params.delete :count if params[:count] == 10
        end

        def compose_query_string(params)
          return "" if params.empty?
          
          pair_strings = params.map { |pair| pair.join('=') }
          "?" + pair_strings.join('&')
        end
      end
    end
  end
end
