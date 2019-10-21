require "timeout"

module Lapidar
  RSpec.describe Runner do
    subject(:runner) { described_class.new(buschtelefon_endpoint_mock) }

    let(:buschtelefon_endpoint_mock) { instance_double(Buschtelefon::NetTattler, port: 4242) }

    before do
      allow(Lapidar::Persistence).to receive(:load_chain).and_return(nil)
      allow(Lapidar::Persistence).to receive(:save_chain).and_return(nil)
    end

    describe "#new" do
      it { is_expected.to be_a(Runner) }

      context "when there is chain data available" do
        let(:chain_double) { instance_double(Chain, blocks: [build(:genesis_block)]) }

        before do
          allow(Lapidar::Persistence).to receive(:load_chain).and_return(chain_double)
        end

        it "it is being loaded into buschtelefon" do
          expect(buschtelefon_endpoint_mock).to receive(:load_messages)
          runner
        end
      end
    end

    describe "#start" do
      context "when network support is mocked away" do
        let(:message) { Buschtelefon::Gossip.new(build(:genesis_block).to_h.to_json) }
        let(:gossip_source_double) { instance_double(Buschtelefon::RemoteTattler, inquire: true) }

        it "runs for some time" do
          expect(buschtelefon_endpoint_mock).to receive(:feed).at_least(:once)
          expect(buschtelefon_endpoint_mock).to receive(:listen).and_yield(message, gossip_source_double).at_least(:once)

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
