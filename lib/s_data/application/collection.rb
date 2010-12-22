module SData
  module Application
    module Actions
      module Collection
        protected

        def query_params
          request.env["rack.request.query_hash"]
        end

        def dataset
          params[:dataset]
        end
        
        def collection_url
          sdata_resource.sdata_resource_kind_url(dataset)
        end
        
        def collection_scope
          @collection_scope ||= SData::Collection::Scope.new(sdata_resource, params, target_user, pagination).tap { |scope| scope.scope! }
        end

        def pagination
          @pagination ||= SData::Collection::Pagination.new(sdata_options[:feed][:default_items_per_page],
                                                            sdata_options[:feed][:maximum__items_per_page],
                                                            params[:startIndex].to_i,
                                                            params[:count].to_i)
        end

        def feed_links
          @feed_links ||= SData::Collection::Links.new(collection_url, pagination, query_params)
        end
      end
    end
  end
end
