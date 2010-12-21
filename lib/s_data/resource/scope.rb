module SData
  module Resource
    class Scope < Struct.new(:resource_class, :baze_scope)
      extend Forwardable
      
      def_delegators :baze_scope, :count, :count_with_deleted
      
      def all(*params)
        resource_class.collection(baze_scope.all(*params))
      end

      def all_with_deleted(*params)
        resource_class.collection(baze_scope.find_with_deleted(:all, *params))
      end

      # This just adds activerecord (mysql) pagination to the scope
      def with_pagination(pagination)
        scoped(:offset => pagination.zero_based_start_index, :limit => pagination.records_to_return)
      end

      # This calls with_scope on the base class domain object to add
      # whatever conditions you've passed to the current scope
      def with_conditions(conditions)
        scoped(:conditions => conditions)
      end

      # This is used to take predicates from the sdata protocol sent
      # across the wire and convert them to activerecord find
      # conditions and yield an activerecord scope withthese conditions
      def with_predicate(raw_predicate)
        if raw_predicate.nil?
          self
        else
          predicate = SData::Predicate.parse(resource_class.payload_map.baze_fields, raw_predicate)
          with_conditions(predicate.to_conditions)
        end
      end

      def scoped(conditions)
        clone_with_baze_scope(baze_scope.scoped(conditions))
      end

      def clone_with_baze_scope(new_scope)
        self.class.new(resource_class, new_scope)
      end

      # TODO: rename bb_model_id and bb_model_type to model_id and
      # model_type if the request contains the $linked predicate then
      # we want to only return records from the collection which have
      # an entry in the sd_uuids table. (for details see the sdata
      # spec:
      # http://interop.sage.com/daisy/sdataSync/LinkAndSync.html)
      
      def with_linking(linking, uuid=nil)
        if linking
          uuid_clause = uuid.nil? ? '' : "uuid = '#{Predicate.strip_quotes(uuid)}' and "
          tablename = resource_class.baze_class_name.tableize
          with_conditions("#{tablename}.id IN (SELECT bb_model_id FROM sd_uuids WHERE #{uuid_clause}(bb_model_type = '#{resource_class.baze_class.name}') and (sd_class = '#{SData.sdata_name(resource_class)}'))")
        else
          self
        end
      end
    end
  end
end
