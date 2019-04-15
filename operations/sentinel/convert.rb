module Sentinel
  class Convert < ::Operations::Base
    subject :data_stream

    def _call
      result = []

      source_hash = SmarterCSV.process(data_stream, col_sep: ', ')
      logger.info "Source hash : #{source_hash}"

      groupped_by_route = source_hash.group_by { |route| route[:route_id] }
      logger.info "Groupped by route: #{groupped_by_route}"

      groupped_by_route.each do |route_id, routes|
        next if routes.count < 2

        routes.each { |route| route[:time] = Time.strptime(route[:time], '%Y-%m-%dT%H:%M:%S%z').utc }
        logger.info " - ROUTE ID: #{route_id}. With converted time: #{routes}"

        start_node = routes.min { |route| route[:time] }
        end_node = routes.max { |route| route[:time] }
        logger.info " - ROUTE ID: #{route_id}. Start route: #{start_node}"
        logger.info " - ROUTE ID: #{route_id}. End route: #{end_node}"

        r = {
          start_node: start_node[:node],
          end_node: end_node[:node],
          start_time: start_node[:time].strftime('%FT%T'),
          end_time: end_node[:time].strftime('%FT%T')
        }
        logger.info " - ROUTE ID: #{route_id}. Result: #{r}"

        result << r
      end

      result
    end
  end
end
