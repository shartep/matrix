module Loophole
  class Convert < ::Operations::Base
    param :routes
    param :node_pairs

    def _call
      # CONSIDER: it will be good to implement parallel processing here in chunks, especially taking in mind that
      # it can bes a lot of data, but taking in mind that we should join routes and nodes hashes, this task becomes
      # much more complicated than just split data on chunks and process them in different threads, maybe it make sense
      # to use some kind of Database for this
      node_pairs_hash = JSON.parse(node_pairs.read, symbolize_names: true)
                             .fetch(:node_pairs)
                             .tap { |source_hash| logger.info "Source Node pairs hash : #{source_hash}" }
                             .to_h(&method(:convert_node_pair))
                             .tap { |converted_nodes| logger.info "Source Node pairs converted hash : #{converted_nodes}"}

      JSON.parse(routes.read, symbolize_names: true)
          .fetch(:routes)
          .tap { |source_hash| logger.info "Source Routes hash : #{source_hash}" }
          .map { |route| join(route, node_pairs_hash) }
          .compact
    end

    private

      def allowed?
        performer.admin?
      end

      # convert {id: '1', start_node: 'lambda', end_node: 'tau'} to
      # [1, { start_node: 'lambda', end_node: 'tau' }] array
      def convert_node_pair(node_pair)
        [
          node_pair[:id],
          node_pair.slice(:start_node, :end_node)
        ]
      end

      # return nil if it is impossible to join
      def join(route, node_pairs)
        node_pair = node_pairs[route[:node_pair_id]]
        return if node_pair.blank?

        {
          start_node: node_pair[:start_node],
          end_node: node_pair[:end_node],
          start_time: route[:start_time].gsub('Z', ''),
          end_time: route[:end_time].gsub('Z', '')
        }.tap { |result| logger.info " - ROUTE ID: #{route[:route_id]}, NODE_ID: #{route[:node_pair_id]}. Result: #{result}" }
      end
  end
end
