lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lapidar/version"

Gem::Specification.new do |spec|
  spec.name = "lapidar"
  spec.version = Lapidar::VERSION
  spec.authors = ["Josua Schmid"]
  spec.email = ["josua.schmid@renuo.ch"]

  spec.summary = 'Carve it in stone. Only that these stones are easy to move across the internet.
This is a multi purpose blockchain on which you can build some custom business logic.'
  spec.description = 'This is a custom blockchain with a working network layer. It just mines and receives blocks
and evaluates block order and correctness. Build any distributed business logic on top of it.'
  spec.homepage = "https://github.com/renuo/lapidar"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/renuo/lapidar"
  spec.metadata["changelog_uri"] = "https://github.com/renuo/lapidar/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_dependency "buschtelefon", "~> 0.2"
  spec.add_development_dependency "bundler", ">= 1.17"
  spec.add_development_dependency "factory_bot", "~> 5.0"
  spec.add_development_dependency "paint", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "simplecov", "~> 0.17"
  spec.add_development_dependency "standard", "> 0"
end
