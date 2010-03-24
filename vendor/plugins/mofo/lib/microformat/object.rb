unless Object.method_defined?(:try)
  class Object
    def try(property)
      send property if respond_to? property
    end
  end
end
