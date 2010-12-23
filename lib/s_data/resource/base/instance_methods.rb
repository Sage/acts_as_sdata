module SData
  module Resource
    module InstanceMethods
      def sdata_name
        self.class.name.demodulize
      end

      def sdata_node_name
        self.class.sdata_node_name
      end

      def sdata_resource_url(dataset)
        self.class.sdata_resource_kind_url(dataset) + "('#{self.id}')"
      end

      def resource_header_attributes(dataset, included)
        hash = {}
        hash.merge!({"sdata:key" => self.id, "sdata:url" => self.sdata_resource_url(dataset)}) if self.id
        hash.merge!("sdata:descriptor" => self.entry_content) if included.include?("$descriptor")
        hash.merge!("sdata:uuid" => self.uuid.to_s) if self.respond_to?("uuid") && !self.uuid.blank?
        hash
      end

      def sdata_options
        self.class.sdata_options
      end
      
      protected

      def sdata_contract_name
        self.class.sdata_contract_name
      end
      
      def sdata_default_author
        "Billing Boss"
      end

      def entry_title
        title_proc = self.sdata_options[:title]
        title_proc ? instance_eval(&title_proc) : default_entity_title
      end

      def default_entity_title
        "#{self.class.name.demodulize.titleize} #{id}"
      end

      def entry_content
        content_proc = self.sdata_options[:content]
        content_proc ? instance_eval(&content_proc) : default_entry_content
      end
      
      def default_entry_content
        self.class.name
      end

      def instance_url(context)
        "#{self.sdata_resource_url(dataset)}?#{query_params.to_param}"
      end
    end
  end
end
