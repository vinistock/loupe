# frozen_string_literal: true

require_relative "lib/guava/version"

Gem::Specification.new do |spec|
  spec.name          = "guava"
  spec.version       = Guava::VERSION
  spec.authors       = ["Vinicius Stock"]
  spec.email         = ["stock@hey.com"]

  spec.summary       = "A parallel test framework based on Ractors"
  spec.description   = "A parallel test framework based on Ractors"
  spec.homepage      = "https://github.com/vinistock/guava"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/vinistock/guava"
  spec.metadata["changelog_uri"] = "https://github.com/vinistock/guava/blob/master/CHANGELOG.md"

  spec.files = Dir["{exe,lib}/**/*",
                   "MIT-LICENSE",
                   "Rakefile",
                   "README.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "io-console"
end
