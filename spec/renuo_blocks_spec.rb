RSpec.describe RenuoBlocks do
  it 'runs' do
    threads = [
      Thread.new { RenuoBlocks.start_mining(port: 9999, neighbors: [{ host: 'localhost', port: 9995 }]) },
      Thread.new { RenuoBlocks.start_mining(port: 9998, neighbors: [{ host: 'localhost', port: 9996 }]) },
      Thread.new { RenuoBlocks.start_mining(port: 9997, neighbors: [{ host: 'localhost', port: 9997 }]) },
      Thread.new { RenuoBlocks.start_mining(port: 9996, neighbors: [{ host: 'localhost', port: 9998 }]) },
      Thread.new { RenuoBlocks.start_mining(port: 9995, neighbors: [{ host: 'localhost', port: 9999 }]) }
    ]

    sleep(2)
  end
end

