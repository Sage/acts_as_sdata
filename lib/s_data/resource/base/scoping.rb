module SData
  module Resource
    module Scoping
      def sdata_scope_for_context(target_user)
        if SData.enforce_scoping?
          unless has_sdata_scope?
            raise SData::Exceptions::VirtualBase::MissingScope.new("#{self.name}: missing sdata_scope_for_context for #{self.baze_class.name}")
          end
        end
        
        baze_scope = has_sdata_scope? ? self.baze_class.sdata_scope_for_context(target_user) : self.baze_class
        SData::Resource::Scope.new(self, baze_scope)
      end

      def has_sdata_scope?
        self.baze_class.respond_to?(:sdata_scope_for_context)
      end
    end
  end
end
