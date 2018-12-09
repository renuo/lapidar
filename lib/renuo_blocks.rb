require_relative 'renuo_blocks/assessment'
require_relative 'renuo_blocks/block'
require_relative 'renuo_blocks/chain'
require_relative 'renuo_blocks/miner'

require 'json'

module RenuoBlocks
  def self.start_mining(port:, neighbors:)
    chain = Chain.new
    miner = Miner.new
    incoming_blocks = Queue.new

    me = Buschtelefon::NetTattler.new(port: port)
    neighbors.map! { |neighbor_location| Buschtelefon::RemoteTattler.new(neighbor_location) }
    neighbors.each { |neighbor| me.connect(neighbor) }

    Thread.abort_on_exception = true

    consumer = Thread.new do
      until_shutdown do
        chain.add(incoming_blocks.pop)
        print '+'
      rescue

      end
    end

    network_producer = Thread.new do
      until_shutdown do
        me.listen do |message|
          incoming_blocks << Block.new(JSON.parse(message, symbolize_names: true))
        end
      end
    end

    local_producer = Thread.new do
      until_shutdown do
        new_block = miner.mine(chain.blocks.last)

        me.feed(Buschtelefon::Gossip.new(new_block.to_h.to_json))
        incoming_blocks << new_block

        print '⚒ '
      end
    end

    local_producer.join
    network_producer.join
    consumer.join

    puts "\nShutting down…"
  end

  def self.until_shutdown(&block)
    trap 'SIGINT' do
      puts "\nshutting down"
      exit
    end

    loop do
      yield
    end
  end
end
