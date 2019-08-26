module Lapidar
  class Assessment
    def self.valid_link?(previous_block, block)
      hash(previous_block&.hash, block.nonce, block.data) == block.hash
    end

    def self.meets_difficulty?(block)
      block.hash.start_with?("0000")
    end

    def self.genesis?(block)
      first?(block) && valid_link?(nil, block)
    end

    def self.first?(block)
      block.number.zero?
    end

    def self.hash(previous_hash, nonce, data)
      Digest::SHA256.hexdigest("#{previous_hash}-#{nonce}-#{data}")
    end
  end
end
