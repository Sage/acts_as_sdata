module SData
  module Resource
    class Scope < Struct.new(:resource_class, :baze_scope)
      def all(*params)
        resource_class.collection(baze_scope.all(*params))
      end

      def all_with_deleted(*params)
        resource_class.collection(baze_scope.find_with_deleted(:all, *params))
      end

      def with_pagination(pagination, &block)
        yield scoped(:offset => pagination.zero_based_start_index, :limit => pagination.records_to_return)
      end

      def with_conditions(conditions, &block)
        yield scoped(:conditions => conditions)
      end

      def with_predicate(raw_predicate, &block)
        if raw_predicate.nil?
          yield self
        else
          predicate = SData::Predicate.parse(resource_class.payload_map.baze_fields, raw_predicate)
          with_conditions(predicate.to_conditions, &block)
        end
      end

      def scoped(conditions)
        clone_with_baze_scope(baze_scope.scoped(conditions))
      end

      def clone_with_baze_scope(new_scope)
        self.class.new(resource_class, new_scope)
      end

      # TODO: rename bb_model_id and bb_model_type to model_id and model_type
      def with_linking(linking, uuid=nil, &block)
        if linking
          uuid_clause = uuid.nil? ? '' : "uuid = '#{Predicate.strip_quotes(uuid)}' and "
          tablename = resource_class.baze_class_name.tableize
          with_conditions("#{tablename}.id IN (SELECT bb_model_id FROM sd_uuids WHERE #{uuid_clause}(bb_model_type = '#{resource_class.baze_class.name}') and (sd_class = '#{SData.sdata_name(resource_class)}'))", &block)
        else
          yield self
        end
      end
    end
  end
end
