# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module IsbnToolkit
  # Fetch book metadata from external APIs.
  #
  # @example
  #   book = IsbnToolkit::Lookup.fetch("9780132350884")
  #   book.title    # => "Clean Code"
  #   book.authors  # => ["Robert C. Martin"]
  #   book.cover    # => "https://..."
  #
  module Lookup
    Result = Struct.new(:isbn, :title, :authors, :publisher, :published_date,
                       :description, :cover, :pages, :language, :source,
                       keyword_init: true) do
      def found?
        !title.nil? && !title.empty?
      end
    end

    module_function

    # Fetch metadata for an ISBN
    #
    # @param isbn [String]
    # @param source [Symbol] :open_library or :google_books
    # @return [Result]
    # @raise [LookupError] on network errors
    def fetch(isbn, source: :open_library)
      digits = isbn.to_s.gsub(/[^0-9Xx]/, "").upcase

      case source
      when :open_library
        fetch_open_library(digits)
      when :google_books
        fetch_google_books(digits)
      else
        raise Error, "Unknown source: #{source}. Use :open_library or :google_books"
      end
    end

    # Fetch from Open Library API
    #
    # @param isbn [String]
    # @return [Result]
    def fetch_open_library(isbn)
      url = "https://openlibrary.org/api/books?bibkeys=ISBN:#{isbn}&format=json&jscmd=data"
      uri = URI(url)

      response = Net::HTTP.get_response(uri)
      raise LookupError, "Open Library returned #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      book_data = data["ISBN:#{isbn}"]

      return empty_result(isbn, :open_library) unless book_data

      authors = book_data.dig("authors")&.map { |a| a["name"] } || []

      Result.new(
        isbn: isbn,
        title: book_data["title"],
        authors: authors,
        publisher: book_data.dig("publishers", 0, "name"),
        published_date: book_data["publish_date"],
        description: book_data.dig("notes") || book_data.dig("excerpts", 0, "text"),
        cover: book_data.dig("cover", "large") || book_data.dig("cover", "medium"),
        pages: book_data["number_of_pages"],
        language: book_data.dig("languages", 0, "key")&.sub("/languages/", ""),
        source: :open_library
      )
    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => e
      raise LookupError, "Network error: #{e.message}"
    end

    # Fetch from Google Books API
    #
    # @param isbn [String]
    # @return [Result]
    def fetch_google_books(isbn)
      url = "https://www.googleapis.com/books/v1/volumes?q=isbn:#{isbn}"
      uri = URI(url)

      response = Net::HTTP.get_response(uri)
      raise LookupError, "Google Books returned #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      return empty_result(isbn, :google_books) if data["totalItems"].to_i.zero?

      info = data.dig("items", 0, "volumeInfo") || {}

      Result.new(
        isbn: isbn,
        title: info["title"],
        authors: info["authors"] || [],
        publisher: info["publisher"],
        published_date: info["publishedDate"],
        description: info["description"],
        cover: info.dig("imageLinks", "thumbnail"),
        pages: info["pageCount"],
        language: info["language"],
        source: :google_books
      )
    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => e
      raise LookupError, "Network error: #{e.message}"
    end

    def empty_result(isbn, source)
      Result.new(isbn: isbn, source: source)
    end
    private_class_method :empty_result
  end
end
