require "timeout"
require "kafka"

RSpec.describe Lapidar do
  describe "#runner" do
    before do
      allow(Lapidar::Persistence).to receive(:load_chain).and_return(nil)
      allow(Lapidar::Persistence).to receive(:save_chain).and_return(nil)
    end

    it "returns a runner" do
      def read_kafka_topics
        kafka = Kafka.new(["192.168.1.140:9092"], client_id: "lapidar-client")
        puts kafka.topics
      end

      def publish_block(block)
        kafka = Kafka.new(["192.168.1.140:9092"], client_id: "lapidar-client")
        kafka.deliver_message(block.to_json, topic: "lapidar-events")
      end

      def receive_block
        kafka = Kafka.new(["192.168.1.140:9092"], client_id: "lapidar-client")
        kafka.each_message(topic: "lapidar-events") do |message|
          puts message.value
        end
      end

      read_kafka_topics
      block = build(:torah_block)
      publish_block(block.to_h)


      # expect(
      #   Lapidar.runner(host: "127.0.0.1", port: 9999, neighbors: [{host: "example.com", port: 9999}])
      # ).to be_a(Lapidar::Runner)
    end
  end
end
