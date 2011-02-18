module SData
  module Application
    module Actions
      module Collection
        protected

        def collection_scope
          @collection_scope ||= SData::Collection::Scope.new(sdata_resource, target_user, pagination, context).tap { |scope| scope.scope! }
        end

        def pagination_params
          @pagination_params ||= SData::Collection::PaginationParams.new(sdata_options[:feed], params)
        end

        def feed_links
          @feed_links ||= SData::Collection::Links.new(sdata_resource.collection_base_url(context), pagination, context.query_params, collection_scope.resource_count)
        end
      end
    end
  end
end
