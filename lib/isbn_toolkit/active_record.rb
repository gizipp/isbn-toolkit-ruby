# frozen_string_literal: true

module IsbnToolkit
  # ActiveRecord validation helpers.
  #
  # @example
  #   class Book < ActiveRecord::Base
  #     validates :isbn, isbn: { format: :isbn13 }
  #     validates :isbn, isbn: true  # accepts any valid format
  #   end
  #
  class IsbnValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return if value.blank? && options[:allow_blank]
      return if value.nil? && options[:allow_nil]

      isbn = IsbnToolkit::ISBN.new(value)

      unless isbn.valid?
        record.errors.add(attribute, options[:message] || "is not a valid ISBN")
        return
      end

      if options[:format]
        case options[:format]
        when :isbn13
          unless isbn.isbn13?
            record.errors.add(attribute, options[:message] || "must be ISBN-13 format")
          end
        when :isbn10
          unless isbn.isbn10?
            record.errors.add(attribute, options[:message] || "must be ISBN-10 format")
          end
        end
      end
    rescue IsbnToolkit::InvalidISBN
      record.errors.add(attribute, options[:message] || "is not a valid ISBN")
    end
  end
end
