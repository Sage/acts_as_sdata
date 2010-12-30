module SData
  module Application
    module Actions
      module Collection
        protected

        def collection_scope
          @collection_scope ||= SData::Collection::Scope.new(sdata_resource, target_user, pagination, context).tap { |scope| scope.scope! }
        end

        def pagination
          @pagination ||= SData::Collection::Pagination.new(sdata_options[:feed][:default_items_per_page],
                                                            sdata_options[:feed][:maximum__items_per_page],
                                                            params[:startIndex].to_i,
                                                            invalid_num?(params[:count]) ? nil : params[:count].to_i)
        end

        def feed_links
          @feed_links ||= SData::Collection::Links.new(sdata_resource.collection_url(context), pagination, context)
        end

        def invalid_num?(num)
          num.nil? or num.empty? or (num.to_i.to_s != num)
        end
      end
    end
  end
end
