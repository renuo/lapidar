require "json"
require "buschtelefon"

require_relative "lapidar/assessment"
require_relative "lapidar/block"
require_relative "lapidar/chain"
require_relative "lapidar/miner"
require_relative "lapidar/persistence"
require_relative "lapidar/runner"
require_relative "lapidar/version"

module Lapidar
  def self.runner(port:, neighbors:)
    network_endpoint = Buschtelefon::NetTattler.new(port: port)
    neighbors.map! { |neighbor_location| Buschtelefon::RemoteTattler.new(neighbor_location) }
    neighbors.each { |neighbor| network_endpoint.connect(neighbor) }

    Runner.new(network_endpoint)
  end
end
