module SData
  class Collection
    class Scope < Struct.new(:resource_class, :target_user, :pagination_params, :context)
      attr_reader :resource_count, :resources

      def scope!
        self.resource_count = context.linked? ? sdata_scope.count_with_deleted : sdata_scope.count
        self.resources = context.linked? ? paginated_sdata_scope.all_with_deleted : paginated_sdata_scope.all
      end

      def paginated_sdata_scope
        sdata_scope.with_pagination(pagination_params)
      end

      def sdata_scope
        initial_scope.with_predicate(where_clause_from_params).with_linking(context.linked?)
      end

      protected

      attr_writer :resource_count, :resources

      def where_clause_from_params
        # this implementation is 3-4 times faster than previous one
        # RADAR: this assumes only one clause, and does no error checking
        expression = context.params.detect{|k,v|  v.nil? && k.is_a?(String) && k[0...6] == 'where '}
        expression.nil? ? nil : expression.first
      end

      def initial_scope
        resource_class.sdata_scope_for_context(target_user)
      end
      
      # Yields the sdata model class (a SData::VirtualBase) scoped with context scope and any 
      # where clause (sdata predicate) found in the request.
      # To use the context scope, VirtualBase subclasses should set their baze_class to a
      # named_scope called sdata_scope_for_context that takes a single param. This named_scope
      # will be passed the controller object.
      #
      #     named_scope :sdata_scope_for_context, 
      #                 lambda{|context| {:conditions =>{:user_id => context.current_user}}}
      def with_sdata_scope #:yields: scoped_resource_class
        yield sdata_scope
      end
    end
  end  
end
