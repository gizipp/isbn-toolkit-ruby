# frozen_string_literal: true

module IsbnToolkit
  # Convert between ISBN-10, ISBN-13, and EAN-13 formats.
  module Converter
    module_function

    # Convert ISBN-10 to ISBN-13
    #
    # @param isbn10 [String] 10-digit ISBN string
    # @return [String] 13-digit ISBN string
    # @raise [InvalidISBN] if input is not a valid ISBN-10
    def isbn10_to_isbn13(isbn10)
      digits = isbn10.to_s.gsub(/[^0-9Xx]/, "").upcase
      raise InvalidISBN, "Invalid ISBN-10 length: #{digits.length}" unless digits.length == 10

      # Drop check digit, prepend 978
      prefix = "978#{digits[0..8]}"

      # Calculate new check digit
      check = calculate_isbn13_check(prefix)
      "#{prefix}#{check}"
    end

    # Convert ISBN-13 to ISBN-10 (only works for 978-prefix)
    #
    # @param isbn13 [String] 13-digit ISBN string
    # @return [String] 10-digit ISBN string
    # @raise [InvalidISBN] if 979-prefix (no ISBN-10 equivalent)
    def isbn13_to_isbn10(isbn13)
      digits = isbn13.to_s.gsub(/[^0-9]/, "")
      raise InvalidISBN, "Invalid ISBN-13 length: #{digits.length}" unless digits.length == 13
      raise InvalidISBN, "979-prefix ISBNs cannot be converted to ISBN-10" unless digits.start_with?("978")

      # Take first 9 digits, calculate ISBN-10 check
      base = digits[3..11]
      check = calculate_isbn10_check(base)
      "#{base}#{check}"
    end

    # Calculate ISBN-13 check digit
    #
    # @param prefix [String] first 12 digits
    # @return [String] single check digit
    def calculate_isbn13_check(prefix)
      digits = prefix.to_s.gsub(/[^0-9]/, "")
      raise InvalidISBN, "Need 12 digits for ISBN-13 check" unless digits.length == 12

      sum = digits.chars.each_with_index.sum do |char, i|
        weight = i.even? ? 1 : 3
        char.to_i * weight
      end

      ((10 - (sum % 10)) % 10).to_s
    end

    # Calculate ISBN-10 check digit
    #
    # @param base [String] first 9 digits
    # @return [String] check digit (0-9 or X)
    def calculate_isbn10_check(base)
      digits = base.to_s.gsub(/[^0-9]/, "")
      raise InvalidISBN, "Need 9 digits for ISBN-10 check" unless digits.length == 9

      sum = digits.chars.each_with_index.sum do |char, i|
        char.to_i * (10 - i)
      end

      check = (11 - (sum % 11)) % 11
      check == 10 ? "X" : check.to_s
    end

    # Format ISBN-13 with hyphens (best-effort grouping)
    #
    # @param isbn13 [String] 13-digit ISBN string
    # @return [String] formatted string, e.g. "978-0-13-235088-4"
    def format_isbn13(isbn13)
      digits = isbn13.to_s.gsub(/[^0-9]/, "")
      raise InvalidISBN, "Invalid ISBN-13 length" unless digits.length == 13

      "#{digits[0..2]}-#{digits[3]}-#{digits[4..5]}-#{digits[6..11]}-#{digits[12]}"
    end

    # Format ISBN-10 with hyphens (best-effort grouping)
    #
    # @param isbn10 [String] 10-digit ISBN string
    # @return [String] formatted string, e.g. "0-13-235088-2"
    def format_isbn10(isbn10)
      digits = isbn10.to_s.gsub(/[^0-9Xx]/, "").upcase
      raise InvalidISBN, "Invalid ISBN-10 length" unless digits.length == 10

      "#{digits[0]}-#{digits[1..2]}-#{digits[3..8]}-#{digits[9]}"
    end
  end
end
