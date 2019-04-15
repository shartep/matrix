require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'active_support'
require 'active_support/core_ext'

Dir.glob(File.expand_path('lib/**/*.rb'), &method(:require))
Dir.glob(File.expand_path('[!(spec/|lib/)]**/**/*.rb'), &method(:require))
logger = TaggedLogger.new(Logger.new(STDOUT), 'app')


logger.info 'APPLICATION START'

stream_sentinels = File.open('./sentinels/routes.csv', 'r')
current_user = nil

sentinels = Sentinel::Convert.new(current_user, data_stream: stream_sentinels).call

logger.info "Result: #{sentinels}"

logger.info 'APPLICATION COMPLETE'
