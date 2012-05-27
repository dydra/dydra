# This is free and unencumbered software released into the public domain.

module Dydra::RPC
  ##
  # Represents a Dydra.com RPC error condition.
  class Error < IOError
    include Message
    # TODO
  end # Error
end # Dydra::RPC
