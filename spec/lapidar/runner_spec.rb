require "timeout"

module Lapidar
  RSpec.describe Runner do
    subject(:runner) { described_class.new(network_endpoint_mock) }

    let(:network_endpoint_mock) { instance_double(Buschtelefon::NetTattler, port: 4242) }

    describe "#new" do
      it { is_expected.to be_a(Runner) }
    end

    describe "#start" do
      context "when network support is mocked away" do
        let(:message) { Buschtelefon::Gossip.new(build(:genesis_block).to_h.to_json) }

        it "runs for some time" do
          expect(network_endpoint_mock).to receive(:feed).at_least(:once)
          expect(network_endpoint_mock).to receive(:listen).and_yield(message).at_least(:once)

          expect {
            Timeout.timeout(1) do
              runner.punch_queue << "test"
              runner.start
            end
          }.to raise_exception(Timeout::Error)

          runner.stop
        end
      end
    end
  end
end
