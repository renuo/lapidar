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
    buschtelefon_endpoint = Buschtelefon::NetTattler.new(port: port)

    neighbors.each do |neighbor_location|
      buschtelefon_endpoint.connect_remote(neighbor_location)
    end

    Runner.new(buschtelefon_endpoint)
  end
end
