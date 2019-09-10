module Lapidar
  class Chain
    attr_reader :block_stacks

    def initialize
      @block_stacks = []
    end

    # TODO: Queue up future blocks for later use
    # TODO: Check for duplicates and dont add them to the chains
    def add(block)
      raise "future block?" if block.number > @block_stacks.count
      raise "invalid block" unless valid?(block)

      @block_stacks[block.number] ||= []
      @block_stacks[block.number].push(block) unless @block_stacks[block.number].map(&:hash).include?(block.hash)

      # Rebalance if second to last block has more than one candidate
      rebalance if !contested?(block.number) && contested?(block.number - 1)
    end

    # For each positition in the chain the candidate positioned first is considered the valid one
    def blocks
      @block_stacks.map { |candidates| candidates&.first }
    end

    def to_colorful_string(depth = 0)
      [*0..depth].map do |level|
        @block_stacks.map do |block_stack|
          if block_stack[level]
            number_display = block_stack[level].number.to_s
            if defined? Paint
              number_display = Paint[number_display, block_stack[level].hash[-6..-1]] # use last hash digits as color
              number_display = Paint[number_display, :bright, :underline] if level == 0 # emphasize preferred chain
              number_display
            end
            number_display
          else
            " " * block_stack[0].number.to_s.length # padding by digit count
          end
        end.join(" ")
      end.join("\n")
    end

    private

    def valid?(block)
      return true if Assessment.genesis?(block) # early valid if genesis
      return false if Assessment.first?(block) # early invalid if fake genesis
      return false unless Assessment.meets_difficulty?(block) # early invalid if difficulty not met

      # Check if there's an existing parent
      @block_stacks[block.number - 1].any? do |previous_block|
        Assessment.valid_link?(previous_block, block)
      end
    end

    # If a new last block comes in, we realign the first blocks to build the longest chain
    def rebalance
      winning_block = @block_stacks.last.first
      parent_position = @block_stacks.count - 2

      while contested?(parent_position)
        # TODO: Is there's a smarter way to persistently select a winner than sorting the competition
        @block_stacks[parent_position].sort_by! do |previous_block|
          Assessment.valid_link?(previous_block, winning_block) ? 0 : 1
        end

        winning_block = @block_stacks[parent_position].first
        parent_position -= 1
      end
    end

    # Contested evaluates to true if there blocks are competing for the same position in the blockchain
    def contested?(block_number)
      @block_stacks[block_number].count > 1
    end
  end
end
