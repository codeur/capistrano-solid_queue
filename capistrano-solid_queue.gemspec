# frozen_string_literal: true

require_relative "lib/capistrano/solid_queue/version"

Gem::Specification.new do |spec|
  spec.name = "capistrano-solid_queue"
  spec.version = Capistrano::SolidQueue::VERSION
  spec.authors = ["Brice TEXIER"]
  spec.email = ["brice@codeur.com"]

  spec.summary = "Adds support for SolidQueue to Capistrano 3.x"
  spec.description = "Adds support for SolidQueue to Capistrano 3.x"
  spec.homepage = "https://github.com/codeur/capistrano-solid_queue"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/codeur/capistrano-solid_queue"
  spec.metadata["changelog_uri"] = "https://github.com/codeur/capistrano-solid_queue/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", ">= 3.0"
end
