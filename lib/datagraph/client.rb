module Datagraph
  ##
  # Datagraph.org API client library.
  module Client
    autoload :Account,    'datagraph/client/account'
    autoload :Repository, 'datagraph/client/repository'
    autoload :Query,      'datagraph/client/query'
  end
end
