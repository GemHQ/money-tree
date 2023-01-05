# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "money-tree/version"

Gem::Specification.new do |spec|
  spec.name = "money-tree"
  spec.version = MoneyTree::VERSION
  spec.authors = ["Micah Winkelspecht", "Afri Schoedon"]
  spec.email = ["winkelspecht@gmail.com", "gems@q9f.cc"]
  spec.description = %q{A Ruby Gem implementation of Bitcoin HD Wallets}
  spec.summary = %q{Bitcoin Hierarchical Deterministic Wallets in Ruby! (Bitcoin standard BIP0032)}
  spec.homepage = "https://github.com/GemHQ/money-tree"
  spec.license = "MIT"

  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.metadata = {
    "homepage_uri" => "https://github.com/GemHQ/money-tree",
    "source_code_uri" => "https://github.com/GemHQ/money-tree",
    "github_repo" => "https://github.com/GemHQ/money-tree",
    "bug_tracker_uri" => "https://github.com/GemHQ/money-tree/issues",
  }.freeze

  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = ">= 2.7", "< 4.0"

  spec.add_dependency "openssl", "~> 3.1"
  spec.add_dependency "bech32", "~> 1.3"
end
