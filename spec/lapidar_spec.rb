require "timeout"

RSpec.describe Lapidar do
  describe "#runner" do
    before do
      allow(Lapidar::Persistence).to receive(:load_chain).and_return(nil)
      allow(Lapidar::Persistence).to receive(:save_chain).and_return(nil)
    end

    it "returns a runner" do
      expect(
        Lapidar.runner(host: "127.0.0.1", port: 9999, neighbors: [{host: "example.com", port: 9999}])
      ).to be_a(Lapidar::Runner)
    end
  end
end
