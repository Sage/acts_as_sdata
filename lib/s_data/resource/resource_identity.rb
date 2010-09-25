module SData
  module Resource
    module ResourceIdentity
      def register_resource
        key = self.name.demodulize.underscore.to_sym
        (self.registered_resources ||= {})[key] = self
      end

      def define_own_sdata_options
        class << self
          attr_accessor :sdata_options
        end
        self.sdata_options = {}
      end
    end
  end
end
