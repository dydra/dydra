# This is free and unencumbered software released into the public domain.

module Dydra
  ##
  # A mixin that implements the `#inspect` and `#inspect!` methods.
  module Inspectable
    ##
    # Returns a developer-friendly representation of this object.
    #
    # @return [String]
    def inspect
      Kernel.sprintf("#<%s:%#0x(%s)>", self.class.name, self.__id__, self.to_s)
    end

    ##
    # Outputs a developer-friendly representation of this object to the
    # standard error stream.
    #
    # @return [void]
    def inspect!
      Kernel.warn(self.inspect)
    end
  end # Inspectable
end # Dydra
