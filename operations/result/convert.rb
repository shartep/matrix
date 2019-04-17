module Result
  class Send < ::Operations::Base
    subject :result
    param :passphrase

    def _call
      result.each do |source, list|
        list.each do |route|
          http_client.post_json(:routes, route.merge(source: source))
                     .then(&method(:parse_response))
                     .tap { |response| logger.info 'Get response', response: response }
        end
      end
    end

    private

      memoize def http_client
        HttpClient.new(passphrase)
      end

      def parse_response(response)
        JSON.parse(response.body.gsub(/({:)|(, :)|(=>)/, '{:' => '{', ', :' => ', ', '=>' => ':'))
      end
  end
end
