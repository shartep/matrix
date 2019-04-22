module Sniffer
  class Convert < ::Operations::Base
    INPUT_TIME_FORMAT = '%Y-%m-%dT%H:%M:%S%z'.freeze
    OUTPUT_TIME_FORMAT = '%FT%T'.freeze

    param :routes
    param :sequences
    param :node_times

    def _call
      # CONSIDER: it will be good to implement parallel processing here in chunks, especially taking in mind that
      # there is a lot of data, but taking ikn mind that we should join routes and nodes hashes, this task becomes
      # much more complicated than just split data on chunks and process them in different threads, maybe it make sense
      # to use some kind of Database for this
      routes_hash =
        SmarterCSV.process(routes, col_sep: ', ', force_utf8: true)
                  .tap { |source_hash| logger.info "Source Routes hash : #{source_hash}" }
                  .to_h(&method(:convert_route))
                  .tap { |converted_routes| logger.info "Source Routes converted hash : #{converted_routes}" }

      node_times_hash =
        SmarterCSV.process(node_times, col_sep: ', ', force_utf8: true)
                  .tap { |source_hash| logger.info "Source Node times hash : #{source_hash}" }
                  .to_h(&method(:convert_node_time))
                  .tap { |converted_nodes| logger.info "Source Node times converted hash : #{converted_nodes}" }

      SmarterCSV.process(sequences, col_sep: ', ', force_utf8: true)
                .uniq
                .map { |sequence| join(sequence, routes_hash, node_times_hash) }
                .compact
    end

    private

      def allowed?
        performer.admin?
      end

      # convert {route_id: 1, time: "2030-12-31T13:00:06", time_zone: "UTC±00:00"} to
      # [1, :time_in_utc.object] array
      def convert_route(route)
        # fetch time shift from :tome_zone string, skip "±" as it is not parsed correctly
        zone = route[:time_zone].force_encoding('UTF-8').gsub('±', '+').match(/([+\-]\d.:\d.)/).to_s
        [
          route[:route_id],
          Time.strptime(route[:time] + zone, INPUT_TIME_FORMAT).utc
        ]
      end

      # convert {node_time_id: '1', start_node: 'lambda', end_node: 'tau', duration_in_milliseconds: '1000'} to
      # [1, { start_node: 'lambda', end_node: 'tau', duration_in_milliseconds: '1000' }] array
      def convert_node_time(node_time)
        [
          node_time[:node_time_id],
          node_time.slice(:start_node, :end_node, :duration_in_milliseconds)
        ]
      end

      # return nil if it is impossible to join
      def join(sequence, routes, nodes)
        time_node = nodes[sequence[:node_time_id]]
        start_time = routes[sequence[:route_id]]
        return if time_node.blank? || start_time.blank?

        duration_in_seconds = time_node[:duration_in_milliseconds].to_f/1000.0
        {
          start_node: time_node[:start_node],
          end_node: time_node[:end_node],
          start_time: start_time.strftime(OUTPUT_TIME_FORMAT),
          end_time: (start_time + duration_in_seconds).strftime(OUTPUT_TIME_FORMAT)
        }.tap { |result| logger.info " - ROUTE ID: #{sequence[:route_id]}, NODE_ID: #{sequence[:node_time_id]}. Result: #{result}" }
      end
  end
end
