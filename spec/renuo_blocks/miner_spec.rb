module RenuoBlocks
  RSpec.describe Miner do
    let(:instance) { described_class.new }

    describe '#new' do
      it 'initializes' do
        expect(instance).not_to be_nil
      end
    end

    describe '#mine' do
      subject { instance.mine(base_block) }

      context 'when no previous blocks exist' do
        let(:base_block) { nil }
        it { is_expected.to be_a Block }
      end

      context 'when genesis block has been mined' do
        let(:base_block) { Block.new(1, '000', 0) }
        it { is_expected.to be_a Block }
      end
    end
  end
end
