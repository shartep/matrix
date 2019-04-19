module Sentinel
  class Convert < ::Operations::Base
    INPUT_TIME_FORMAT = '%Y-%m-%dT%H:%M:%S%z'.freeze
    OUTPUT_TIME_FORMAT = '%FT%T'.freeze

    subject :routes

    def _call
      # CONSIDER: it will be good to implement parallel processing here in chunks in case data_stream will be really large
      # but taking in mind that routes with same id can be in different chunks, this task becomes much more complicated
      # than just split data_stream on chunks and process them in different threads
      SmarterCSV.process(routes, col_sep: ', ', value_converters: { time: TimeConverter })
                .tap { |source_hash| logger.info "Source hash : #{source_hash}" }
                .group_by { |route| route[:route_id] }
                .tap { |groupped_by_route| logger.info "Grouped by route: #{groupped_by_route}" }
                .map(&method(:convert_route))
                .compact
    end

    private

      def allowed?
        performer.admin?
      end

      # find start and end node using :time as identifier return hash with required structure
      # return nil when it is not possible to convert
      def convert_route(route_id, routes)
        return if routes.count < 2

        logger.info " - ROUTE ID: #{route_id}. With converted time: #{routes}"

        start_node, end_node = routes.minmax { |route| route[:time] }
        {
          start_node: start_node[:node],
          end_node: end_node[:node],
          start_time: start_node[:time].strftime(OUTPUT_TIME_FORMAT),
          end_time: end_node[:time].strftime(OUTPUT_TIME_FORMAT)
        }.tap { |result| logger.info " - ROUTE ID: #{route_id}. Result: #{result}" }
      end

      module TimeConverter
        def self.convert(time_string)
          Time.strptime(time_string, INPUT_TIME_FORMAT).utc
        end
      end
  end
end
