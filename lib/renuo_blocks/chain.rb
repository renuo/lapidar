module RenuoBlocks
  class Chain
    def initialize
      @blocks = []
    end

    # TODO: Queue up future blocks for later use
    # TODO: Check for duplicates and dont add them to the chains
    def add(block)
      raise 'future block?' if block.number > @blocks.count
      raise 'invalid block' unless valid?(block)

      @blocks[block.number] ||= []
      @blocks[block.number].push(block)

      rebalance if @blocks[block.number - 1].count > 1
    end

    def blocks
      @blocks.map { |candidates| candidates&.first }
    end

    def block_count
      @blocks.count
    end

    private

    def valid?(block)
      return true if Assessment.genesis?(block)               # early valid if genesis
      return false if Assessment.first?(block)                # early invalid if fake genesis
      return false unless Assessment.meets_difficulty?(block) # early invalid if difficulty not met

      @blocks[block.number - 1].any? do |previous_block|
        Assessment.valid_link?(previous_block, block)
      end
    end

    def rebalance

    end
  end
end