require 'rubygems'
require 'bundler'

Bundler.require

require './gitpublisher'

$stdout.sync = true

run GitPublisher
