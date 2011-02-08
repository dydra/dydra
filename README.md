Dydra.com Software Development Kit (SDK) for Ruby
=================================================

This is the official command-line client (CLI) and Ruby software development
kit (SDK) for [Dydra.com](http://dydra.com/), the cloud-hosted RDF & SPARQL
database service.

<https://github.com/dydra/dydra>

Documentation
-------------

<http://dydra.rubyforge.org/>

Dependencies
------------

* [Ruby](http://ruby-lang.org/) (>= 1.8.7) or (>= 1.8.1 with [Backports][])
* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.3.0)
* [SPARQL::Client](http://rubygems.org/gems/sparql-client) (>= 0.0.9)

Installation
------------

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the library, do:

    $ [sudo] gem install dydra

Should you wish to remove the library and binary from your system, do:

    $ [sudo] gem uninstall dydra

Configuration
-------------

The first time you run the `dydra` command, you'll be asked to authenticate.
When you type in your username and password, your API token will be fetched
and stored in the the `~/.dydra/credentials` file in your home directory,
enabling you to bypass the authentication step for future commands.

Environment
-----------

Another way to specify the API token is to set the `DYDRA_TOKEN` environment
variable, which takes precedence over any API token specified in the
`~/.dydra/credentials` file. This can be handy, for example, when executing
a command against another Dydra account you may have:

    $ export DYDRA_TOKEN='R33l6sEnxiExJfOYnZHWs2v06yWd2FUiBZc874vTt6QUSPz96imMf48tqLsz'

Download
--------

To get a local working copy of the development repository, do:

    $ git clone git://github.com/dydra/dydra.git

Alternatively, download the latest development version as a tarball as
follows:

    $ wget http://github.com/dydra/dydra/tarball/master

Mailing List
------------

* <http://groups.google.com/group/dydra>

Authors
-------

* [Arto Bendiken](http://github.com/bendiken) - <http://dydra.com/bendiken>
* [Ben Lavender](http://github.com/bhuga) - <http://dydra.com/bhuga>

Contributors
------------

* [Gabriel Horner](http://github.com/cldwalker) - <http://tagaholic.me/>

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
