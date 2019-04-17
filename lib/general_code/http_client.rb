class HttpClient
  extend Memoist

  Error = Class.new(RuntimeError)

  def initialize(passphrase)
    @passphrase = passphrase
  end

  def get_json(*path, **params)
    request_json(:get, *path, **params)
  end

  def post_json(*path, **params)
    request_json(:post, *path, **params)
  end

  private

    def request_json(method, *path, **params)
      params.merge!(passphrase: @passphrase)

      connection.public_send(method, path.join('/'), **params.compact)
                .tap(&method(:ensure_success))
    end


    memoize def connection
      Faraday.new('https://challenge.distribusion.com/the_one/')
    end

    def ensure_success(response)
      return if (200...400).cover?(response.status)
      fail Error, response.body
    end

    memoize def logger
      TaggedLogger.new(Logger.new(STDOUT), self.class.name)
    end
end
