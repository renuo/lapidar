require "oj"

module Lapidar
  class Persistence
    CONFIG_DIR = File.join(ENV["HOME"], ".lapidar")

    def self.save_chain(filename, chain)
      Dir.mkdir(CONFIG_DIR) unless File.exist?(CONFIG_DIR)
      File.write(File.join(CONFIG_DIR, filename), Oj.dump(chain))
    end

    def self.load_chain(filename)
      Oj.load(File.read(File.join(CONFIG_DIR, filename)))
    rescue
      nil
    end
  end
end
