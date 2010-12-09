module SData
  module Resource
    class Base
      cattr_accessor :registered_resources

      def self.inherited(child)
        raise 'You should derive from SData::Resource::base explicitly in order to provide child class name' if child.name.empty?

        class << child
          include ResourceIdentity
        end

        child.register_resource
        child.define_own_sdata_options

        child.__send__ :include, SData::Traits::VirtualBase
      end
      
      def self.has_sdata_options(options)
        self.sdata_options = options
      end

      def self.initial_scope(&block)
        self.baze_class.named_scope(:sdata_scope_for_context, lambda(&block))
      end

      include InstanceMethods
      include ToAtom
      extend ClassMethods
      extend PayloadMap
      extend Uuid
      extend Scoping
    end
  end
end
