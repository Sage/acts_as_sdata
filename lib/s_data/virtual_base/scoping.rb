module SData
  module Resource
    module Scoping
      def with_pagination(pagination)
        scoped(:offset => pagination.zero_based_start_index, :limit => pagination.records_to_return)
      end

      def with_conditions(conditions)
        scoped(:conditions => conditions)
      end

      def with_predicate(raw_predicate)
        predicate = SData::Predicate.parse(self.payload_map.baze_fields, raw_predicate)
        with_conditions(predicate.to_conditions)
      end

      # TODO: rename bb_model_id and bb_model_type to model_id and model_type
      def with_linking(linking, uuid=nil)
        if linking
          uuid_clause = uuid.nil? ? '' : "uuid = '#{Predicate.strip_quotes(uuid)}' and "
          tablename = self.baze_class_name.tableize
          with_conditions("#{tablename}.id IN (SELECT bb_model_id FROM sd_uuids WHERE #{uuid_clause}(bb_model_type = '#{baze_class_name}') and (sd_class = '#{sdata_name}'))")
        else
          self
        end
      end
      
      def sdata_scope_for_context(context)
        has_sdata_scope = self.baze_class.respond_to?(:sdata_scope_for_context)
        if SData.enforce_scoping?
          unless has_sdata_scope
            raise SData::Exceptions::VirtualBase::MissingScope.new("#{self.name}: missing sdata_scope_for_context for #{self.baze_class.name}")
          end
        end
        scope = has_sdata_scope ? self.baze_class.sdata_scope_for_context(context) : self.baze_class
        ScopedVirtualBase.new(scope, self)
      end

      def with_baze(active_record_instance, &block)
        self.with_baze_class(active_record_instance.class, &block)
      end
      
      # RADAR: not threadsafe
      def with_baze_class(class_or_scope)
        old_baze_class, self.baze_class = self.baze_class, class_or_scope
        yield
        self.baze_class = old_baze_class
      end

      def scoped(options)
        ActiveRecord::NamedScope::Scope.new(self.baze_class, options)
      end
    end
  end
end
