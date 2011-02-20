module SData
  module Resource
    module ClassMethods
      def find_by_sdata_instance_id(value)
        attribute = self.sdata_options[:instance_id]

        attribute.nil? ?
        self.find(value.to_i) :
          self.first(:conditions => { attribute => value })
      end

      def sdata_node_name
        @sdata_node_name ||= self.name.demodulize.camelize(:lower)
      end  

      def sdata_contract_name
        @sdata_contract_name ||= SData.sdata_contract_name(self.name)
      end
      
      def sdata_resource_kind_url(dataset)
        #FIXME: will change when we support bk use cases
        postfix = self.sdata_node_name.pluralize
        "#{SData.endpoint}/#{dataset}/#{postfix}"
      end

      def sdata_date(date_time)
        SData::Formatting.format_date_time(date_time)
      end

      def collection_base_url(context)
        sdata_resource_kind_url(context.dataset)
      end

      def collection_url(context)
        "#{collection_base_url(context)}?#{context.query_params.to_param}"
      end
    end
  end
end
