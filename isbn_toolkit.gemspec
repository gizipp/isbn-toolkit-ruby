# frozen_string_literal: true

require_relative "lib/isbn_toolkit/version"

Gem::Specification.new do |spec|
  spec.name          = "isbn_toolkit"
  spec.version       = IsbnToolkit::VERSION
  spec.authors       = ["Gilang R. Aprianto"]
  spec.email         = ["gilang@gizipp.com"]

  spec.summary       = "All-in-one ISBN toolkit for Ruby — validate, convert, lookup metadata."
  spec.description   = <<~DESC
    isbn_toolkit provides everything you need to work with ISBNs:
    validate ISBN-10/ISBN-13, convert between formats, lookup book metadata
    from Open Library and Google Books, and ActiveRecord validations.
  DESC
  spec.homepage      = "https://github.com/gizipp/isbn_toolkit"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?("spec/", "test/", ".github/", "bin/", ".")
    end
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "net-http", ">= 0.1.0"
end
