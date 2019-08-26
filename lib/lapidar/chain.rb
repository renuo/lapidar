module Lapidar
  class Chain
    def initialize
      @blocks = []
    end

    # TODO: Queue up future blocks for later use
    # TODO: Check for duplicates and dont add them to the chains
    def add(block)
      raise "future block?" if block.number > @blocks.count
      raise "invalid block" unless valid?(block)

      @blocks[block.number] ||= []
      @blocks[block.number].push(block)

      # Rebalance if second to last block has more than one candidate
      rebalance if !contested?(block.number) && contested?(block.number - 1)
    end

    # For each positition in the chain the candidate positioned first is considered the valid one
    def blocks
      @blocks.map { |candidates| candidates&.first }
    end

    private

    def valid?(block)
      return true if Assessment.genesis?(block) # early valid if genesis
      return false if Assessment.first?(block) # early invalid if fake genesis
      return false unless Assessment.meets_difficulty?(block) # early invalid if difficulty not met

      # Check if there's an existing parent
      @blocks[block.number - 1].any? do |previous_block|
        Assessment.valid_link?(previous_block, block)
      end
    end

    # If a new last block comes in, we realign the first blocks to build the longest chain
    def rebalance
      winning_block = @blocks.last.first
      parent_position = @blocks.count - 2

      while contested?(parent_position)
        # TODO: Is there's a smarter way to persistently select a winner than sorting the competition
        @blocks[parent_position].sort_by! do |previous_block|
          Assessment.valid_link?(previous_block, winning_block) ? 0 : 1
        end

        winning_block = @blocks[parent_position].first
        parent_position -= 1
      end
    end

    # Contested evaluates to true if there blocks are competing for the same position in the blockchain
    def contested?(block_number)
      @blocks[block_number].count > 1
    end
  end
end
