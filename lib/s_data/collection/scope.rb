module SData
  class Collection
    class Scope < Struct.new(:resource_class, :linked)
      attr_reader :entry_count, :entries
      
      attr_accessor :linked
      
      def linked?
        !! linked
      end

      def scope!
        with_paginated_sdata_scope do |scope|
          self.entry_count = scope.count
          self.entries = linked? ? scope.all_with_deleted : scope.all
        end
      end

      protected

      attr_writer :entry_count, :entries

      def is_linked_request?
        params[:condition] == "$linked"
      end

      def where_clause_from_params
        # this implementation is 3-4 times faster than previous one
        # RADAR: this assumes only one clause, and does no error checking
        expression = params.detect{|k,v|  v.nil? && k.is_a?(String) && k[0...6] == 'where '}
        expression.nil? ? nil : expression.first
      end

      def with_paginated_sdata_scope #:yields: scoped_model_class
        with_sdata_scope do |scope|
          model_class.with_pagination(zero_based_start_index, records_to_return) do
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
      def with_sdata_scope #:yields: scoped_model_class
        scope = model_class.sdata_scope_for_context(self)
        
        model_class.with_predicate(where_clause_from_params) do
          model_class.with_linking(linked?) do
            # ????! how do two methods above affect this scope?!?!?
            yield scope
          end
        end
      end
    end
  end  
end
