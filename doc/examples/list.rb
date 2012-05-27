#!/usr/bin/env ruby
# This is free and unencumbered software released into the public domain.

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib')))
require 'dydra'

ACCOUNT = ENV['ACCOUNT'] || 'jhacker' # the demo account

puts "Authenticating..."
Dydra.authenticate!

puts "Listing all repositories belonging to '#{ACCOUNT}':"
account = Dydra::Account.new(ACCOUNT)
account.each do |repository|
  puts "* #{repository}"
end
