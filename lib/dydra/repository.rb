# This is free and unencumbered software released into the public domain.

module Dydra
  ##
  # Represents a Dydra.com RDF repository.
  #
  # @see http://docs.dydra.com/sdk/ruby
  class Repository < Resource
    SPEC = %r(^([^/]+)/([^/]+)$) # /account/repository

    ##
    # @param  [Hash{Symbol => Object}] options
    # @option options [String] :account_name (nil)
    # @yield  [repository]
    # @yieldparam [Repository] repository
    # @return [Enumerator]
    def self.each(options = {}, &block)
      if block_given?
        result = RPC::Client.call(:ListRepositories, ENV['DYDRA_ACCOUNT'])
        result.each do |(account_name, repository_name)| # FIXME
          block.call(Repository.new(account_name, repository_name))
        end
      end
      enum_for(:each, options)
    end

    ##
    # The account the repository belongs to.
    #
    # @return [Account]
    attr_reader :account

    ##
    # The machine-readable name of the repository.
    #
    # @return [String]
    attr_reader :name

    ##
    # The short description of the repository.
    #
    # @return [String]
    attr_reader :summary

    ##
    # The long description of the repository.
    #
    # @return [String]
    attr_reader :description

    ##
    # When the repository was first created.
    #
    # @return [DateTime]
    attr_reader :created

    ##
    # When the repository was last updated.
    #
    # @return [DateTime]
    attr_reader :updated

    [:summary, :description, :created, :updated].each do |property|
      class_eval(<<-EOS)
        def #{property}(); info['#{property}']; end
      EOS
    end

    ##
    # @param  [String, #to_s] user
    # @param  [String, #to_s] name
    def initialize(user, name = nil)
      if name.nil?
        if user =~ /\// # a user/repo form
          (user, name) = user.split(/\//)
        else
          name = user
          user = ENV['DYDRA_ACCOUNT']
        end
      end
      if user.nil? && !(ENV['DYDRA_TOKEN'].nil?)
        raise RepositoryMisspecified, "You must specify a repository owner name when using token-only authentication"
      end
      @account = case user
        when Account then user
        else Account.new(user.to_s)
      end
      @name = name.to_s
      super(Dydra::URL / @account.name / @name)
    end

    ##
    # Sugar for creating a repository, as `.new` instantiates an existing one.
    #
    # @param  [String] repository_name
    # @return [Repository]
    def self.create!(*args)
      self.new(*args).create!
    end

    ##
    # List of repository names. Will use the given user if supplied.
    #
    # @param  [String] account
    # @return [Array<String>]
    def self.list(user = nil)
      user ||= ENV['DYDRA_ACCOUNT']
      raise RepositoryMisspecified, "List requires a user in token-only authentication mode" if user.nil?
      RPC::Client.call(:ListRepositories, [user])
    end

    ##
    # Creates this repository on Dydra.com.
    #
    # @return [Operation]
    def create
      Operation.new(RPC::Client.call(:CreateRepository, [path]))
    end
    alias_method :create!, :create

    ##
    # Destroys this repository from Dydra.com.
    #
    # @return [Operation]
    def destroy
      Operation.new(RPC::Client.call(:DestroyRepository, [path]))
    end
    alias_method :destroy!, :destroy

    ##
    # Deletes all data in this repository.
    #
    # @return [Operation]
    def clear
      Operation.new(RPC::Client.call(:ClearRepository, [path]))
    end
    alias_method :clear!, :clear

    ##
    # Imports data from a URL into this repository.
    #
    # @param  [String, #to_s] url
    # @return [Operation]
    def import!(url, opts = {})
      base_uri = opts[:base_uri] # || File.dirname(url)
      context = opts[:context] || ''
      if url =~ %r(^(http|https|ftp )://)
        url = url                                     # already a url
        base_uri = opts[:base_uri] || ''              # let the server determine base URI
      else
        base_uri = opts[:base_uri] || url             # Base URI is the file itself unless specified
        url = upload_local_file(self, url)            # local file to be uploaded
      end
      options = {:context => context.to_s, :base_uri => base_uri.to_s} # TODO
      Operation.new(RPC::Client.call(:Import, path, url.to_s, options))
    end

    ##
    # Returns the number of RDF statements in this repository.
    #
    # @return [Integer]
    def count
      RPC::Client.call(:CountStatements, [path])
    end

    ##
    # @private
    # @return [Hash]
    def info
      RPC::Client.call(:DescribeRepository, [path])
    end

    ##
    # Returns a string representation of the repository name.
    #
    # @return [String]
    def to_s
      [account.name, name].join('/')
    end
  end # Repository
end # Dydra
