require 'thread'
require_relative 'renuo_blocks/assessment'
require_relative 'renuo_blocks/block'
require_relative 'renuo_blocks/chain'
require_relative 'renuo_blocks/miner'

module RenuoBlocks
  def self.start_mining
    miner = Miner.new
    new_blocks = Queue.new

    consumer = Thread.new do
      until_shutdown do
        new_block = new_blocks.pop
        print '+'
      end
    end

    network_producer = Thread.new do
      until_shutdown do
        sleep 1
        [Block.new(nil, '0001', 'net'), Block.new(nil, '0002', 'net')].each do |incoming_block|
          new_blocks << incoming_block
        end
      end
    end

    local_producer = Thread.new do
      until_shutdown do
        new_block = miner.mine(last_block)
        # publish block
        print '⚒ '

        new_blocks << new_block
      end
    end

    local_producer.join
    network_producer.join
    consumer.join

    puts "\nShutting down…"
  end

  def self.last_block
    @last_block ||= nil
  end

  def self.known_blocks
    @known_blocks || []
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
