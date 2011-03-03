module SData
  module Application
    module Actions
      module Collection
        protected

        def collection_scope
          @collection_scope ||= SData::Collection::Scope.new(sdata_resource, target_user, pagination_params, context).tap { |scope| scope.scope! }
        end

        def pagination_params
          @pagination_params ||= SData::Collection::PaginationParams.new(sdata_options[:feed], params)
        end

        def pagination
          @pagination ||= SData::Collection::Pagination.new(pagination_params, collection_scope.resource_count)
        end

        def feed_links
          @feed_links ||= SData::Collection::Links.new(url_composer, pagination)
        end

        def url_composer
          @url_composer ||= SData::Collection::Links::UrlComposer.new(sdata_resource.collection_base_url(context), context.query_params)
        end
      end
    end
  end
end
