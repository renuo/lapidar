require "logger"

module Lapidar
  class Runner
    attr_accessor :chain, :network_endpoint, :logger

    def initialize(network_endpoint)
      @logger = Logger.new(StringIO.new)
      @network_endpoint = network_endpoint
      @chain = Persistence.load_chain("#{@network_endpoint.port}.json") || Chain.new
      @incoming_blocks = Queue.new
      @should_stop = nil
      @threads = []
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
      Persistence.save_chain("#{@network_endpoint.port}.json", @chain)
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

    def local_producer
      Thread.new do
        miner = Miner.new
        until @should_stop
          begin
            new_block = miner.mine(@chain.blocks.last)
            @network_endpoint.feed(Buschtelefon::Gossip.new(new_block.to_h.to_json))
            @incoming_blocks << new_block
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
        @network_endpoint.listen do |gossip|
          break if @should_stop

          begin
            incoming_json = JSON.parse(gossip.message, symbolize_names: true)

            @incoming_blocks << Block.new(
              number: incoming_json[:number].to_i,
              hash: incoming_json[:hash].to_s,
              nonce: incoming_json[:nonce].to_i,
              data: incoming_json[:data].to_s,
              created_at: incoming_json[:created_at].to_f
            )
          rescue JSON::ParserError, ArgumentError => e
            @logger.debug("network_producer") { "Incoming block isn't valid: #{e.message}" }
          end
        end
      end
    end
  end
end
