# frozen_string_literal: true

module IsbnToolkit
  # ISBN checksum validation.
  #
  # @see https://www.isbn-international.org/content/what-isbn
  module Validator
    module_function

    # Validate ISBN-13 checksum (mod 10)
    #
    # @param digits [String] 13-digit string
    # @return [Boolean]
    def isbn13_valid?(digits)
      return false unless digits.match?(/\A\d{13}\z/)

      sum = digits.chars.each_with_index.sum do |char, i|
        weight = i.even? ? 1 : 3
        char.to_i * weight
      end

      (sum % 10).zero?
    end

    # Validate ISBN-10 checksum (mod 11)
    #
    # @param digits [String] 10-digit string (last char can be X)
    # @return [Boolean]
    def isbn10_valid?(digits)
      return false unless digits.match?(/\A\d{9}[\dX]\z/)

      sum = digits.chars.each_with_index.sum do |char, i|
        value = char == "X" ? 10 : char.to_i
        value * (10 - i)
      end

      (sum % 11).zero?
    end

    # Validate a raw ISBN string (auto-detect format)
    #
    # @param isbn [String]
    # @return [Boolean]
    def valid?(isbn)
      digits = isbn.to_s.gsub(/[^0-9Xx]/, "").upcase

      case digits.length
      when 13 then isbn13_valid?(digits)
      when 10 then isbn10_valid?(digits)
      else false
      end
    end
  end
end
