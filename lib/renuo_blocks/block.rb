module RenuoBlocks
  class Block
    attr_reader :number, :hash, :data, :nonce, :created_at

    def initialize(number, hash, nonce, data = nil, created_at = Time.now)
      @number = number
      @hash = hash
      @nonce = nonce
      @data = data
      @created_at = created_at
    end
  end
end
