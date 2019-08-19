RSpec.describe RenuoBlocks do
  let(:instance) { described_class.new }

  describe "#start_mining" do
    subject { instance }

    it { is_expected.not_to be_nil }
  end
end
