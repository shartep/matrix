require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'dotenv/load'
require 'active_support'
require 'active_support/core_ext'
require 'open-uri'
require 'optparse'
require 'zip'

Dir.glob(File.expand_path('lib/**/*.rb'), &method(:require))
Dir.glob(File.expand_path('[!(spec/|lib/)]**/**/*.rb'), &method(:require))
