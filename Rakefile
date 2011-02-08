#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'rubygems'
require 'dydra'

VERSION_STRING = ENV['VERSION'] || File.read('VERSION').chomp

desc "Executes RSpec on all specs in the spec/ directory"
task :spec do
  sh "bundle exec rspec spec/"
end

namespace :version do
  desc "Bumps the version number in the VERSION and lib/dydra/version.rb files"
  task :bump do
    new_version_string = VERSION_STRING.split('.').map(&:to_i)
    old_version_tiny   = new_version_string[-1]
    new_version_tiny   = old_version_tiny + 1
    new_version_string[-1] = new_version_tiny
    new_version_string = new_version_string.map(&:to_s).join('.')
    sh "echo '#{new_version_string}' > VERSION"
    sh "sed -i '' 's/TINY  = #{old_version_tiny}/TINY  = #{new_version_tiny}/' lib/dydra/version.rb"
    sh "git ci -m 'Bumped the version to #{new_version_string}.' VERSION lib/dydra/version.rb"
  end

  desc "Tags the current revision as release #{VERSION_STRING}"
  task :tag do
    sh "git tag -s #{VERSION_STRING} -m 'Released version #{VERSION_STRING}.'"
  end
end

desc "Builds the dydra-#{VERSION_STRING}.gem binary"
task :build do
  sh "mkdir -p pkg"
  sh "gem build .gemspec && mv *.gem pkg/"
end

desc "Builds the dydra-#{VERSION_STRING}.tgz, dydra-#{VERSION_STRING}.tbz and dydra-#{VERSION_STRING}.zip archives"
task :package => ['VERSION', '.gemspec'] do
  gemspec = eval(File.read('.gemspec'))
  package = gemspec.name.to_s
  version = gemspec.version.to_s
  sh "mkdir -p pkg"
  sh "git archive --prefix=#{package}-#{version}/ --format=tar #{version} | gzip > pkg/#{package}-#{version}.tgz"
  sh "git archive --prefix=#{package}-#{version}/ --format=tar #{version} | bzip2 > pkg/#{package}-#{version}.tbz"
  sh "git archive --prefix=#{package}-#{version}/ --format=zip #{version} > pkg/#{package}-#{version}.zip"
end

namespace :yardoc do
  desc "Rebuilds the YARD documentation in the doc/yard/ directory"
  task :build do
    sh "mkdir -p doc/yard"
    sh "bundle exec yardoc"
  end

  desc "Uploads the YARD documentation to http://dydra.rubyforge.org/"
  task :upload do
    host = ENV['HOST'] || 'rubyforge.org'
    sh "rsync -azv doc/yard/ #{host}:/var/www/gforge-projects/dydra/"
  end
end
desc "Rebuilds the YARD documentation in doc/yard/"
task :yardoc => 'yardoc:build'
