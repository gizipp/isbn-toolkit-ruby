# frozen_string_literal: true

require_relative "isbn_toolkit/version"
require_relative "isbn_toolkit/isbn"
require_relative "isbn_toolkit/validator"
require_relative "isbn_toolkit/converter"
require_relative "isbn_toolkit/lookup"
require_relative "isbn_toolkit/active_record" if defined?(ActiveRecord)

# ISBN Toolkit — validate, convert, and lookup ISBNs.
#
# @example Basic usage
#   isbn = IsbnToolkit::ISBN.new("978-0-13-235088-4")
#   isbn.valid?      # => true
#   isbn.isbn13       # => "9780132350884"
#   isbn.isbn10       # => "0132350882"
#
# @example Validation
#   IsbnToolkit.valid?("9780132350884")       # => true
#   IsbnToolkit.valid?("1234567890")          # => false
#
# @example Metadata lookup
#   book = IsbnToolkit.lookup("9780132350884")
#   book.title    # => "Clean Code"
#   book.authors  # => ["Robert C. Martin"]
#
module IsbnToolkit
  class Error < StandardError; end
  class InvalidISBN < Error; end
  class LookupError < Error; end

  # Quick validation
  #
  # @param isbn [String]
  # @return [Boolean]
  def self.valid?(isbn)
    ISBN.new(isbn).valid?
  rescue InvalidISBN
    false
  end

  # Convert ISBN string to ISBN object
  #
  # @param isbn [String]
  # @return [ISBN]
  def self.parse(isbn)
    ISBN.new(isbn)
  end

  # Lookup book metadata
  #
  # @param isbn [String]
  # @param source [Symbol] :open_library or :google_books
  # @return [Lookup::Result]
  def self.lookup(isbn, source: :open_library)
    Lookup.fetch(isbn, source: source)
  end
end
