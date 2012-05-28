# This is free and unencumbered software released into the public domain.

require 'json'

module Dydra::RPC
  ##
  # Constants defined for the Dydra.com RPC interface.
  module Protocol
    ##
    # The Dydra.com RPC interface version.
    API_VERSION = '2012-06-01'

    ##
    # The JSON-RPC protocol version to use.
    JSONRPC_VERSION = 2.0
  end # Protocol
end # Dydra::RPC
