module SData
  module Resource
    class Base
      cattr_accessor :registered_resources

      def self.inherited(child)
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

      include InstanceMethods
      extend ClassMethods
      extend SData::PayloadMap
    end
  end
end 
