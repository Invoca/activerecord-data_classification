# frozen_string_literal: true

require_relative "lib/active_record/data_classification/version"

Gem::Specification.new do |spec|
  spec.name    = "activerecord-data_classification"
  spec.version = ActiveRecord::DataClassification::VERSION
  spec.authors = ["Invoca Development"]
  spec.email   = ["development@invoca.com"]

  spec.summary     = "An ActiveRecord extension for classifying models and fields as confidential data"
  spec.description = "An ActiveRecord extension for classifying models and fields as confidential data"
  spec.homepage    = "https://github.com/invoca/activerecord-data_classification"
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata = {
    "source_code_uri" => spec.homepage,
    "allowed_push_host" => "https://rubygems.org"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.glob("{exec,lib}/**/*") + ['README.md', 'LICENSE']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel",   ">= 6.0"
  spec.add_dependency "activerecord",  ">= 6.0"
  spec.add_dependency "activesupport", ">= 6.0"
end
