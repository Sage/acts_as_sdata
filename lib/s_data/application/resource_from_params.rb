module SData
  module Application
    module ResourceFromParams
      def sdata_resource_name
        params[:sdata_resource].underscore.singularize.to_sym
      end

      def sdata_resource
        SData::Resource::Base.registered_resources[sdata_resource_name]
      end
    end
  end
end
