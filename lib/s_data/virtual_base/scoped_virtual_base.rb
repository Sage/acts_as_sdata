module SData
    class ScopedVirtualBase
    attr_accessor :scope, :virtual_base_class

    def initialize(scope, virtual_base_class)
      @scope = scope
      @virtual_base_class = virtual_base_class
    end

    def find(*params)

      virtual_base_class.new(scope.find(*params))
    end

    def count(*params)
      scope.count(*params)
    end

    def first(*params)
      virtual_base_class.new(scope.first(*params))
    end

    def all(*params)
      virtual_base_class.collection(scope.all(*params))
    end
    
    def all_with_deleted(*params)
      virtual_base_class.collection(scope.find_with_deleted(:all, *params))
    end
  end
end
