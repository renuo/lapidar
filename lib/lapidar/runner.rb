require "logger"

module Lapidar
  class Runner
    attr_reader :chain, :punch_queue, :buschtelefon_endpoint, :logger

    def initialize(buschtelefon_endpoint)
      @logger = Logger.new(StringIO.new)
      @buschtelefon_endpoint = buschtelefon_endpoint
      @chain = Persistence.load_chain("#{@buschtelefon_endpoint.port}.json") || Chain.new
      @incoming_blocks = Queue.new
      @punch_queue = SizedQueue.new(1)
      @should_stop = nil
      @threads = []

      # Reload currently strongest chain into buschtelefon_endpoint
      if @chain.blocks.any?
        @buschtelefon_endpoint.load_messages(@chain.blocks.map(&:to_h).map(&:to_json))
      end
    end

    def start
      @should_stop = false
      @threads = [consumer, local_producer, network_producer]
      @threads.each { |t| t.abort_on_exception = true }
      @threads.each(&:join)
    end

    def stop
      @should_stop = true
      Thread.pass
      Persistence.save_chain("#{@buschtelefon_endpoint.port}.json", @chain)
      @threads.each(&:exit)
    end

    private

    def consumer
      Thread.new do
        until @should_stop
          begin
            @chain.add(@incoming_blocks.pop)
            @logger.info("consumer") { "+" }
          rescue => e
            @logger.debug("consumer") { "Block cannot be added to chain: #{e.message}" }
            @logger.info("consumer") { "_" }
          end
        end
      end
    end

    def publish_block(block)
      kafka = Kafka.new(["192.168.1.140:9092"], client_id: "lapidar-client")
      kafka.deliver_message(block.to_json, topic: "lapidar-events")
    end

    def local_producer
      Thread.new do
        miner = Miner.new
        until @should_stop
          begin
            new_block = miner.mine(@chain.blocks.last, @punch_queue.pop)
            @incoming_blocks << new_block

            # We need to let the consumer digest the block, otherwise we maybe mine the same block twice.
            # Notice that we feed the block into the network soon because adoption is also important.
            Thread.pass

            publish_block(new_block.to_h)

            # @buschtelefon_endpoint.feed(Buschtelefon::Gossip.new(new_block.to_h.to_json))
            @logger.info("local_producer") { "!" }
          rescue => e
            @logger.debug("local_producer") { "Mint block isn't valid: #{e.message}" }
            @logger.info("local_producer") { "F" }
          end
        end
      end
    end

    def network_producer
      Thread.new do
        kafka = Kafka.new(["192.168.1.140:9092"], client_id: "lapidar-client")
        kafka.each_message(topic: "lapidar-events") do |message|
          incoming_json = JSON.parse(message.value, symbolize_names: true)

          @incoming_blocks << Block.new(
            number: incoming_json[:number].to_i,
            hash: incoming_json[:hash].to_s,
            nonce: incoming_json[:nonce].to_i,
            data: incoming_json[:data].to_s,
            created_at: incoming_json[:created_at].to_f
          )
        end
      end
    end
  end
end
