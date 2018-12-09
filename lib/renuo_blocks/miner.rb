require 'digest'

module RenuoBlocks
  class Miner
    def initialize
      @stomach = Digest::SHA2.new(256)
    end

    def mine(base_block, data = '')
      base_block ||= god
      nonce = 0
      nonce += 1 until meets_difficulty?(digest(base_block, nonce, data))
      Block.new(number: base_block.number + 1, hash: digest(base_block, nonce, data), nonce: nonce, data: data)
    end

    private

    def digest(base_block, nonce, data)
      @stomach.hexdigest("#{base_block.hash}-#{nonce}-#{data}")
    end

    def meets_difficulty?(digest)
      digest.start_with?('0000')
    end

    def god
      # Virtual block descending from Heaven to create the genesis block
      Block.new(number: -1, hash: nil, nonce: nil)
    end
  end
end
