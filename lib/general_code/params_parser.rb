# helper class responsible for application params interaction
class ParamsParser
  def self.current_user
    options = {}
    OptionParser.new do |parser|
      parser.banner = 'Usage: app.rb [options]'

      parser.on('-u', '--user USER', 'User Name (identifier, like `neo`)') do |value|
        options[:name] = value
      end

      parser.on('-p', '--password PASSWORD', 'User password (for admin users only)') do |value|
        options[:password] = value
      end
    end.parse!

    User.authorize!(options)
  end
end
