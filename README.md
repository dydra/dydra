Dydra.com Software Development Kit (SDK) for Ruby
=================================================

This is the official command-line client (CLI) and Ruby software development
kit (SDK) for [Dydra.com][], the cloud-hosted RDF & SPARQL database service.

<https://github.com/dydra/dydra>

Examples
--------

### Authenticating with API token

    Dydra.authenticate!(:token => api_token)

### Enumerating your repositories

    account = Dydra::Account.new('jhacker')
    account.each do |repository|
      puts repository
    end

### Accessing a repository belonging to your account

    account = Dydra::Account.new('jhacker')
    repository = account['foaf']

Documentation
-------------

<http://dydra.rubyforge.org/>

Dependencies
------------

* [Ruby](http://ruby-lang.org/) (>= 1.8.7) or (>= 1.8.1 with [Backports][])
* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.3.0)
* [SPARQL::Client](http://rubygems.org/gems/sparql-client) (>= 0.0.9)

Note: the instructions in this README, and the operation of the library
itself, implicitly assume a Unix system (Mac OS X, Linux, or *BSD) at
present. Patches improving Windows support are most welcome.

Installation
------------

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the SDK and CLI, do:

    $ [sudo] gem install dydra

Should you wish to remove the SDK and CLI from your system, do:

    $ [sudo] gem uninstall dydra

Configuration
-------------

### ~/.dydra/credentials

The first time you run the `dydra` command, you'll be asked to authenticate.
When you type in your username and password, your API token will be fetched
and stored in the the `~/.dydra/credentials` file in your home directory,
enabling you to bypass the authentication step for future commands.

Environment
-----------

### Specifying the API token

Another way to specify the API token is to set the `DYDRA_TOKEN` environment
variable, which takes precedence over any API token specified in the
`~/.dydra/credentials` file. This can be handy, for example, when executing
a one-off command against another Dydra account you may have:

    $ export DYDRA_TOKEN='R33l6sEnxiExJfOYnZHWs2v06yWd2FUiBZc874vTt6QUSPz96imMf48tqLsz'

### Using a SOCKS proxy

The command-line client optionally supports using a [SOCKS][] proxy to
access [Dydra.com][]. To make use of this functionality, install the
[Socksify][] library for Ruby and set the `SOCKS_SERVER` environment
variable to point to your local SOCKS proxy:

    $ [sudo] gem install socksify
    $ export SOCKS_SERVER='127.0.0.1:1080'

[SOCKS]:    http://en.wikipedia.org/wiki/SOCKS
[Socksify]: http://rubygems.org/gems/socksify

Download
--------

To get a local working copy of the development repository, do:

    $ git clone git://github.com/dydra/dydra.git

Mailing List
------------

* <http://groups.google.com/group/dydra>

Authors
-------

* [Arto Bendiken](https://github.com/bendiken) - <http://dydra.com/bendiken>
* [Ben Lavender](https://github.com/bhuga) - <http://dydra.com/bhuga>
* [Josh Huckabee](https://github.com/jhuckabee) - <http://dydra.com/jhuckabee>

Contributors
------------

* [Gabriel Horner](http://github.com/cldwalker) - <http://tagaholic.me/>

Contributing
------------

* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `.gemspec`, `VERSION`, or `AUTHORS` files. If you need to
  change them, do so on your private branch only.
* Do feel free to add yourself to the `CREDITS` file and the corresponding
  list in the `README`. Alphabetical order applies.

License
-------

This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying {file:UNLICENSE} file.

[Ruby]:       http://ruby-lang.org/
[RDF]:        http://www.w3.org/RDF/
[RDF.rb]:     http://rdf.rubyforge.org/
[YARD]:       http://yardoc.org/
[YARD-GS]:    http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:        http://unlicense.org/#unlicensing-contributions
[Backports]:  http://rubygems.org/gems/backports
[Dydra.com]:  http://dydra.com/
