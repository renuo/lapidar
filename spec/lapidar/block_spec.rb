module Lapidar
  RSpec.describe Block do
    subject(:block) { described_class.new(number: nil, hash: "abcdef", nonce: 0) }

    describe "#new" do
      it { is_expected.to be_a(Block) }
      it { is_expected.to have_attributes(created_at: within(0.1).of(Time.now.to_f)) }
    end

    describe "#to_h" do
      subject { block.to_h }

      it { is_expected.to be_a(Hash) }
      it { is_expected.to include(:number, :hash, :nonce, :data, :created_at) }
    end

    describe "#==" do
      subject { block == other_block }

      context "when compared to itself" do
        let(:other_block) { block }

        it { is_expected.to be(true) }
      end

      context "when compared to something different" do
        let(:other_block) { build(:bible_block) }

        it { is_expected.to be(false) }
      end

      context "when compared to something with the same attributes" do
        let(:other_block) { build(:block, block.to_h) }

        it { is_expected.to be(true) }
      end
    end
  end
end
