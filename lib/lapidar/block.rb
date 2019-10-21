module Lapidar
  class Block
    attr_reader :number, :hash, :data, :nonce, :created_at

    def initialize(number:, hash:, nonce:, data: nil, created_at: Time.now.to_f)
      @number = number
      @hash = hash
      @nonce = nonce
      @data = data
      @created_at = created_at
    end

    def to_h
      {
        number: @number,
        hash: @hash,
        nonce: @nonce,
        data: @data,
        created_at: @created_at,
      }
    end

    def ==(other)
      to_h == other.to_h
    end
  end
end
