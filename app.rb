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
stream_sniffers = {
  routes: File.open('./sniffers/routes.csv', 'r'),
  sequences: File.open('./sniffers/sequences.csv', 'r'),
  node_times: File.open('./sniffers/node_times.csv', 'r'),
}
stream_loopholes = {
  routes: File.open('./loopholes/routes.json', 'r'),
  node_pairs: File.open('./loopholes/node_pairs.json', 'r'),
}
current_user = nil
passphrase = 'Kans4s-i$-g01ng-by3-bye'

result = {}

result[:sentinels] = Sentinel::Convert.new(current_user, data_stream: stream_sentinels).call
result[:sniffers] = Sniffer::Convert.new(current_user, stream_sniffers).call
result[:loopholes] = Loophole::Convert.new(current_user, stream_loopholes).call

logger.info 'Sentinels', result: result[:sentinels]
logger.info 'Sniffers', result: result[:sniffers]
logger.info 'Loopholes', result: result[:loopholes]

Result::Send.new(current_user,result: result, passphrase: passphrase).call

logger.info 'APPLICATION COMPLETE'
