require './env.rb'
logger = TaggedLogger.new(Logger.new(STDOUT), 'app')

current_user = ParamsParser.current_user

logger.info 'APPLICATION START'
logger.info "Authenticate user - #{current_user}"

passphrase = ENV['PASSPHRASE']

SOURCES = {
  Sentinel => %w[routes],
  Sniffer => %w[routes sequences node_times],
  Loophole => %w[routes node_pairs]
}

SOURCES.each do |klass, files|
  source_name = klass.name.pluralize.downcase
  stream = Util::Read.new(current_user, files: files, source: source_name, passphrase: passphrase).call
  routes = klass::Convert.new(current_user, stream).call
  logger.info klass.name, result: routes
  Util::Send.new(current_user,routes: routes, source: source_name, passphrase: passphrase).call
end

logger.info 'APPLICATION COMPLETE'
