module RenuoBlocks
  RSpec.describe Chain do
    let(:instance) { described_class.new }

    describe '#new' do
      subject { instance }

      it { is_expected.not_to be_nil }
    end

    describe '#blocks' do
      subject { instance.blocks }

      it { is_expected.to be_an Enumerable }
    end

    describe '#add' do
      subject { lambda { instance.add(incoming_block) } }

      #        ↓
      # [] ⇒ [[0]]
      context 'when given the genesis block' do
        let(:incoming_block) { build(:genesis_block) }

        it { is_expected.to change { instance.blocks[0] }.from(nil).to(incoming_block) }
        it { is_expected.to change { instance.blocks.last }.from(nil).to(incoming_block) }
        it { is_expected.to change { instance.blocks.count }.by(1) }
      end

      context 'when adding a fake genesis block' do
        let(:incoming_block) { Block.new(number: 0, hash: '00000', nonce: 1, data: 'genesis') }

        it { is_expected.to raise_exception('invalid block') }
      end

      # [[0]] ⇒ raise
      context 'when given a late block after gaps' do
        let(:incoming_block) { Block.new(number: 42, hash: '0000042', nonce: 1, data: 'leviticus') }

        before(:each) { instance.add(build(:genesis_block)) }

        it { is_expected.to raise_exception('future block?') }
      end

      #               ↓
      # […[1]] ⇒ […[1,1]]
      context 'when given an already existing block' do
        let(:incoming_block) { build(:torah_block) }

        before(:each) do
          instance.add build(:genesis_block)
          instance.add build(:torah_block)
        end

        it { is_expected.not_to change { instance.blocks[1] } }
        it { is_expected.not_to change { instance.blocks.last } }
        it { is_expected.not_to change { instance.blocks.count } }
      end

      #                     ↓
      # [[1][2a] ⇒ [[1][2a,2b]]
      context 'when working with blocks' do
        context 'when no rebalancing is needed yet' do
          let(:incoming_block) { build(:bible_block) }

          before(:each) do
            instance.add build(:genesis_block)
            instance.add build(:torah_block)
          end

          it { is_expected.not_to change { instance.blocks.last } }
          it { is_expected.not_to change { instance.blocks.count } }
        end

        #              ↓
        # […[1][2a,2b]] ⇒ […[1][2b,2a][3b]]
        context 'when rebalancing is needed' do
          let(:incoming_block) { build(:apocrypha_block) }

          before(:each) do
            instance.add build(:genesis_block)
            instance.add build(:torah_block)
            instance.add build(:bible_block)
          end

          it { is_expected.to change { instance.blocks.last } }
          it { is_expected.to change { instance.blocks.count } }
          it { is_expected.to change { instance.blocks[1].data }.from('torah').to('bible') }
        end
      end
    end
  end
end
