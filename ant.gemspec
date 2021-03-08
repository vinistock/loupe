# frozen_string_literal: true

require_relative "lib/ant/version"

Gem::Specification.new do |spec|
  spec.name          = "ant"
  spec.version       = Ant::VERSION
  spec.authors       = ["Vinicius Stock"]
  spec.email         = ["stock@hey.com"]

  spec.summary       = "Some summary"
  spec.description   = "Some description"
  spec.homepage      = "https://github.com/vinistock/ant"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/vinistock/ant"
  spec.metadata["changelog_uri"] = "https://github.com/vinistock/ant/blob/master/CHANGELOG.md"

  spec.files = Dir["{exe,lib,ext,sig}/**/*",
                   "MIT-LICENSE",
                   "Rakefile",
                   "README.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/ant/extconf.rb"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "thor", "~> 1.1"
end
