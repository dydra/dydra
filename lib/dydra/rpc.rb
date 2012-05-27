# This is free and unencumbered software released into the public domain.

module Dydra
  ##
  # Dydra Remote Procedure Call (RPC) interface support.
  module RPC
    autoload :Client,   'dydra/rpc/client'
    autoload :Error,    'dydra/rpc/error'
    autoload :Message,  'dydra/rpc/message'
    autoload :Request,  'dydra/rpc/request'
    autoload :Response, 'dydra/rpc/response'
  end # RPC
end # Dydra
