# frozen_string_literal: true

module IsbnToolkit
  # Core ISBN object — parse, validate, and convert.
  #
  # @example
  #   isbn = IsbnToolkit::ISBN.new("978-0-13-235088-4")
  #   isbn.valid?  # => true
  #   isbn.isbn13   # => "9780132350884"
  #   isbn.isbn10   # => "0132350882"
  #
  class ISBN
    attr_reader :raw

    # @param isbn [String] raw ISBN string (with or without hyphens/spaces)
    def initialize(isbn)
      raise InvalidISBN, "ISBN cannot be nil" if isbn.nil?
      raise InvalidISBN, "ISBN cannot be empty" if isbn.to_s.strip.empty?

      @raw = isbn.to_s.strip
      @digits = sanitize(@raw)
    end

    # @return [Boolean] whether the ISBN is valid (checksum passes)
    def valid?
      return false unless [10, 13].include?(@digits.length)

      if @digits.length == 13
        Validator.isbn13_valid?(@digits)
      else
        Validator.isbn10_valid?(@digits)
      end
    end

    # @return [Boolean] whether this is an ISBN-13
    def isbn13?
      @digits.length == 13 && @digits.start_with?("978", "979")
    end

    # @return [Boolean] whether this is an ISBN-10
    def isbn10?
      @digits.length == 10
    end

    # Convert to ISBN-13 (returns self if already ISBN-13)
    #
    # @return [String] 13-digit ISBN string
    # @raise [InvalidISBN] if ISBN-10 is invalid
    def to_isbn13
      return @digits if isbn13?

      Converter.isbn10_to_isbn13(@digits)
    end

    # Convert to ISBN-10 (returns self if already ISBN-10)
    #
    # @return [String] 10-digit ISBN string
    # @raise [InvalidISBN] if conversion not possible (979-prefix can't convert)
    def to_isbn10
      return @digits if isbn10?

      Converter.isbn13_to_isbn10(@digits)
    end

    # Get EAN-13 (same as ISBN-13 for 978/979 prefix)
    #
    # @return [String]
    def to_ean13
      to_isbn13
    end

    # Format with hyphens
    #
    # @return [String] e.g. "978-0-13-235088-4"
    def formatted
      digits = isbn13? ? @digits : to_isbn13
      Converter.format_isbn13(digits)
    rescue InvalidISBN
      Converter.format_isbn10(@digits)
    end

    # @return [String] the clean digits only
    def to_s
      @digits
    end

    # @return [Integer] numeric representation (ISBN-13 only)
    def to_i
      to_isbn13.to_i
    end

    def ==(other)
      case other
      when ISBN
        to_isbn13 == other.to_isbn13
      when String
        to_s == sanitize(other) || to_isbn13 == sanitize(other)
      else
        false
      end
    end

    def inspect
      "#<IsbnToolkit::ISBN raw=#{@raw.inspect} digits=#{@digits.inspect} valid=#{valid?}>"
    end

    private

    def sanitize(str)
      str.gsub(/[^0-9Xx]/, "").upcase
    end
  end
end
