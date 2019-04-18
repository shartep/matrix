require './env.rb'

logger = TaggedLogger.new(Logger.new(STDOUT), 'app')


logger.info 'APPLICATION START'

# stream_sentinels = File.open('./sentinels/routes.csv', 'r')
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


stream_sentinels = Sentinel::Read.new(current_user, files: ['routes'], source: :sentinels, passphrase: passphrase).call
sentinels = Sentinel::Convert.new(current_user, stream_sentinels).call
logger.info 'Sentinels', result: sentinels
Result::Send.new(current_user,routes: sentinels, source: :sentinels, passphrase: passphrase).call

sniffers = Sniffer::Convert.new(current_user, stream_sniffers).call
logger.info 'Sniffers', result: sniffers
Result::Send.new(current_user,routes: sniffers, source: :sniffers, passphrase: passphrase).call

loopholes = Loophole::Convert.new(current_user, stream_loopholes).call
logger.info 'Loopholes', result: loopholes
Result::Send.new(current_user,routes: loopholes, source: :loopholes, passphrase: passphrase).call


logger.info 'APPLICATION COMPLETE'
