module RenuoBlocks
  RSpec.describe Block do
    describe '#new' do
      subject { described_class.new(nil, 'abcdef', 0) }

      it 'initializes' do
        expect(subject).not_to be_nil
      end

      it 'sets block creation date and time' do
        expect(subject.created_at).to be_within(0.1).of(Time.now)
      end
    end
  end
end

