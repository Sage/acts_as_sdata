module SData
  class Collection
    class Scope < Struct.new(:resource_class, :params, :pagination)
      attr_reader :entry_count, :entries

      def linked?
        params[:condition] == "$linked"
      end

      def scope!
        with_paginated_sdata_scope do |scope|
          self.entry_count = scope.count
          self.entries = linked? ? scope.all_with_deleted : scope.all
        end
      end

      protected

      attr_writer :entry_count, :entries

      def where_clause_from_params
        # this implementation is 3-4 times faster than previous one
        # RADAR: this assumes only one clause, and does no error checking
        expression = params.detect{|k,v|  v.nil? && k.is_a?(String) && k[0...6] == 'where '}
        expression.nil? ? nil : expression.first
      end

      def with_paginated_sdata_scope #:yields: scoped_model_class
        with_sdata_scope do |scope|
          scope.with_pagination(pagination) do |scope|
            yield scope
          end
        end
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
        scope = resource_class.sdata_scope_for_context(self)

        resource_class.with_predicate(where_clause_from_params) do |scope|
          resource_class.with_linking(linked?) do |scope|
            yield scope
          end
        end
      end
    end
  end  
end
