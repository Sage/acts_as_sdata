module SData
  class Collection
    class Scope < Struct.new(:resource_class, :params, :target_user, :pagination)
      attr_reader :resource_count, :resources

      # grrrr
      def linked?
        params[:condition] == "$linked"
      end

      def scope!
        with_sdata_scope do |scope|
          self.resource_count = linked? ? scope.count_with_deleted : scope.count
          self.resources = linked? ? scope.with_pagination(pagination).all_with_deleted : scope.with_pagination(pagination).all
        end
      end

      protected

      attr_writer :resource_count, :resources

      def where_clause_from_params
        # this implementation is 3-4 times faster than previous one
        # RADAR: this assumes only one clause, and does no error checking
        expression = params.detect{|k,v|  v.nil? && k.is_a?(String) && k[0...6] == 'where '}
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
        yield initial_scope.with_predicate(where_clause_from_params).with_linking(linked?)
      end
    end
  end  
end
