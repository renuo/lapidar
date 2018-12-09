FactoryBot.define do
  factory :block, class: RenuoBlocks::Block do
    initialize_with { new(attributes) }

    created_at Time.now.utc

    factory :genesis_block do
      number 0
      hash { '000085d473edf61798729844f1a3c64017aa4fa93c3c7b34e57c62f6c6b92dbe' }
      nonce 91086
      data 'tenebrae super faciem abyssi'
    end

    factory :torah_block do
      number 1
      hash { '0000f1f08ca28ae14f81c4bbc0c3d09d24de36cde2821bcc82fa082b1b787b2a' }
      nonce 12124
      data 'torah'
    end

    factory :bible_block do
      number 1
      hash { '0000236c35e99838096da4fa23b8fa201b1de81f5ace36b7070ffbc7a0afee16' }
      nonce 76632
      data 'bible'
    end

    factory :apocrypha_block do
      number 2
      hash { '0000f182e8f79e3e80c651b94a690a68e4611c0eed2025083377498b8caea4fc' }
      nonce 151948
      data 'apocrypha'
    end
  end
end
