module Util
  class Read < ::Operations::Base
    subject :files
    param :passphrase
    param :source

    def _call
      result = {}
      content = open(ENV['BASE_URL'] + 'routes?' + { passphrase: passphrase, source: source }.to_query)
      Zip::File.open_buffer(content) do |zip|
        zip.each do |entry|
          logger.info entry.name

          file = files.grep(File.basename(entry.name, '.*')).first
          result[file.to_sym] = StringIO.new(entry.get_input_stream.read) if file.present?
        end
      end

      result
    end
  end
end
