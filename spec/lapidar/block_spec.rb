module Lapidar
  RSpec.describe Block do
    subject(:block) { described_class.new(number: nil, hash: "abcdef", nonce: 0) }

    describe "#new" do
      it { is_expected.to be_a(Block) }
      it { is_expected.to have_attributes(created_at: within(0.1).of(Time.now)) }
    end

    describe "#to_h" do
      subject(:to_h) { block.to_h }

      it { is_expected.to be_a(Hash) }
      it { is_expected.to include(:number, :hash, :nonce, :data, :created_at) }
    end
  end
end
