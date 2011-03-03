module SData
  class Collection
    class Links
      class UrlComposer < Struct.new(:base_url, :query_params)
        def compose_link_url(startIndex)
          params = (query_params || {}).dup
          params[:startIndex] = startIndex

          params.delete :startIndex if params[:startIndex] == 1
          params.delete :count if params[:count] == 10

          unless params.empty?
            pair_strings = params.map { |pair| pair.join('=') }
            query_string = "?" + pair_strings.join('&')
          else
            query_string = ""
          end
          
          base_url + query_string
        end
      end
    end
  end
end
