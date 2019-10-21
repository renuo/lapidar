module Lapidar
  RSpec.describe Chain do
    let(:instance) { described_class.new }

    describe "#new" do
      subject { instance }

      it { is_expected.not_to be_nil }
    end

    describe "#blocks" do
      subject { instance.blocks }

      it { is_expected.to be_an Enumerable }
    end

    describe "#add" do
      subject { -> { instance.add(incoming_block) } }

      # [] ⇒ [[0]]
      context "when given the genesis block" do
        let(:incoming_block) { build(:genesis_block) }

        it { is_expected.to(change { instance.blocks[0] }.from(nil).to(incoming_block)) }
        it { is_expected.to(change { instance.blocks.last }.from(nil).to(incoming_block)) }
        it { is_expected.to(change { instance.blocks.count }.by(1)) }
      end

      # […[1a]] ⇒ […[1a,1b]]
      context "when given an already existing block" do
        let(:incoming_block) { build(:torah_block) }

        before do
          instance.add build(:genesis_block)
          instance.add build(:torah_block)
        end

        it { is_expected.not_to(change { instance.blocks[1] }) }
        it { is_expected.not_to(change { instance.blocks.last }) }
        it { is_expected.not_to(change { instance.blocks.count }) }
      end

      # [[1][2a] ⇒ [[1][2a,2b]]
      context "when working with blocks" do
        context "when no rebalancing is needed yet" do
          let(:incoming_block) { build(:bible_block) }

          before do
            instance.add build(:genesis_block)
            instance.add build(:torah_block)
          end

          it { is_expected.not_to(change { instance.blocks.last }) }
          it { is_expected.not_to(change { instance.blocks.count }) }
        end

        # […[1][2a,2b]] ⇒ […[1][2b,2a][3b]]
        context "when rebalancing is needed" do
          let(:incoming_block) { build(:apocrypha_block) }

          before do
            instance.add build(:genesis_block)
            instance.add build(:torah_block)
            instance.add build(:bible_block)
          end

          it { is_expected.to(change { instance.blocks.last }) }
          it { is_expected.to(change { instance.blocks.count }.by(1)) }
          it { is_expected.to(change { instance.blocks[1].data }.from("torah").to("bible")) }
        end
      end

      # [[0]] ⇒ [[0]]
      context "when adding a fake genesis block" do
        let(:incoming_block) { Block.new(number: 0, hash: "00000", nonce: 1, data: "genesis") }

        it { is_expected.not_to change { instance.blocks } }
      end

      # [[0]] ⇒ [[0]]
      context "when given an unconnected future block" do
        let(:incoming_block) { build(:apocrypha_block) }

        before do
          instance.add(build(:genesis_block))
        end

        it { is_expected.not_to change { instance.blocks.count } }
      end

      # [[0],[1]] ⇒ [[0],[1]]
      context "when given an unconnectable block in the middle" do
        let(:incoming_block) { Block.new(number: 1, hash: "0000042", nonce: 1, data: "lost torah chapters") }

        before do
          instance.add build(:genesis_block)
          instance.add build(:torah_block)
        end

        it { is_expected.not_to change { instance.blocks.count } }
      end

      # [[0]] ⇒ [[0],[1],[2]]
      context "when given a gap block" do
        let(:incoming_block) { build(:bible_block) }

        before do
          instance.add(build(:genesis_block))
          instance.add(build(:apocrypha_block))
        end

        it { is_expected.to change { instance.blocks.count }.by(2) }
      end
    end
  end
end
