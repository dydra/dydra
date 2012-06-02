# This is free and unencumbered software released into the public domain.

module Dydra
  ##
  # Represents a Dydra.com user account.
  #
  # @example Enumerating repositories belonging to an account
  #   account.each_repository do |repository|
  #     puts repository.inspect
  #   end
  #
  # @example Accessing account information
  #   account = Dydra::Account.new('jhacker')
  #   account.url       #=> #<RDF::URI(http://api.dydra.com/jhacker)>
  #   account.name      #=> "jhacker"
  #   account.fullname  #=> "J. Random Hacker"
  #
  # @example Accessing a repository belonging to an account
  #   repository = account[:foaf]
  #
  # @see http://docs.dydra.com/sdk/ruby
  class Account < Resource
    include Enumerable

    SPEC = %r(^([^/]+)$) # /account

    ##
    # Returns `true` if an account with the given `name` exists on
    # Dydra.com.
    #
    # @param  [String, #to_s] name
    # @return [Boolean] `true` or `false`
    def self.exists?(name)
      Account.new(name).exists?
    end

    ##
    # Registers a new user account with Dydra.com.
    #
    # @param  [String] name
    # @param  [Hash{Symbol => Object}] options
    # @option options [String] :email
    # @option options [String] :password
    # @return [Account]
    def self.register!(name, options = {})
      raise NotImplementedError, "#{self}.register!" # TODO
      #RPC::Client.call(:RegisterAccount, [name, options])
      #self.new(name)
    end

    ##
    # The account URL.
    #
    # @example
    #   Dydra::Account.new('jhacker').url       #=> #<RDF::URI(http://api.dydra.com/jhacker)>
    #
    # @return [RDF::URI]
    # @!parse attr_reader :url
    def url
      super
    end

    ##
    # The resource path, relative to <http://dydra.com/>.
    #
    # @example
    #   Dydra::Account.new('jhacker').path      #=> "jhacker"
    #
    # @return [String]
    # @!parse attr_reader :path
    def path
      super
    end

    ##
    # The account name.
    #
    # @example
    #   Dydra::Account.new('jhacker').name      #=> "jhacker"
    #
    # @return [String]
    attr_reader :name

    ##
    # The account holder's email address.
    #
    # Note that you can only access the email address associated with your
    # own account(s); for any other accounts, this will always return `nil`.
    #
    # @example
    #   Dydra::Account.new('jhacker').email     #=> "jhacker@dydra.com"
    #
    # @return [String]
    attr_reader :email

    ##
    # The account holder's full name.
    #
    # @example
    #   Dydra::Account.new('jhacker').fullname  #=> "J. Random Hacker"
    #
    # @return [String]
    attr_reader :fullname

    %w(email fullname).each do |attr_name|
      class_eval(<<-EOS)
        def #{attr_name}(); info['#{attr_name}']; end
      EOS
    end

    ##
    # Initializes an account instance.
    #
    # @param  [String, #to_s] name
    #   a valid account name
    def initialize(name)
      @name = name.to_s
      super(Dydra::URL.join(@name))
    end

    ##
    # Returns basic account info.
    #
    # @return [Hash]
    def info
      RPC::Client.call(:DescribeAccount, [self.name])
    end

    ##
    # Returns a given repository belonging to this account.
    #
    # @example
    #   account = Dydra::Account.new('jhacker')
    #   account.repository('foaf')              #=> #<Dydra::Repository(jhacker/foaf)>
    #   account['foaf']                         #=> #<Dydra::Repository(jhacker/foaf)>
    #
    # @param  [String, #to_s] name
    # @return [Repository]
    def repository(repository_name)
      Repository.new(self, repository_name)
    end
    alias_method :[], :repository

    ##
    # Returns the list of repositories belonging to this account.
    #
    # @example
    #   account = Dydra::Account.new('jhacker')
    #   account.repositories.count              #=> 1
    #
    # @return [Array<Repository>]
    def repositories
      self.each_repository.to_a
    end

    ##
    # Enumerates each repository belonging to this account.
    #
    # @example
    #   account = Dydra::Account.new('jhacker')
    #   account.each_repository do |repository|
    #     puts repository.inspect
    #   end
    #
    # @yield  [repository]
    # @yieldparam  [Repository] repository
    # @yieldreturn [void]
    # @return [Enumerator]
    def each_repository(options = {}, &block)
      if block_given?
        result = RPC::Client.call(:ListRepositories, self.name)
        result.each do |(account_name, repository_name)| # FIXME
          block.call(Repository.new(self, repository_name))
        end
      end
      enum_for(:each_repository, options)
    end
    alias_method :each, :each_repository

    ##
    # Returns a string representation of the account name.
    #
    # @example
    #   account = Dydra::Account.new('jhacker')
    #   account.to_s                            #=> "jhacker"
    #
    # @return [String]
    def to_s
      self.name
    end
  end # Account
end # Dydra
