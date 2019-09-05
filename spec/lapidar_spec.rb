require "timeout"

RSpec.describe Lapidar do
  describe "#runner" do
    it "returns a runner" do
      expect(Lapidar.runner(port: 9999, neighbors: [{host: "example.com", port: 9999}])).to be_a(Lapidar::Runner)
    end
  end
end
