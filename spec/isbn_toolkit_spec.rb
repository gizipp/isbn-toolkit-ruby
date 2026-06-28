# frozen_string_literal: true

RSpec.describe IsbnToolkit do
  it "has a version number" do
    expect(IsbnToolkit::VERSION).not_to be_nil
  end

  describe ".valid?" do
    it "returns true for valid ISBN-13" do
      expect(IsbnToolkit.valid?("9780132350884")).to be true
    end

    it "returns true for valid ISBN-13 with hyphens" do
      expect(IsbnToolkit.valid?("978-0-13-235088-4")).to be true
    end

    it "returns true for valid ISBN-10" do
      expect(IsbnToolkit.valid?("0132350882")).to be true
    end

    it "returns true for valid ISBN-10 with X check digit" do
      expect(IsbnToolkit.valid?("080442957X")).to be true
    end

    it "returns false for invalid ISBN" do
      expect(IsbnToolkit.valid?("1234567890")).to be false
    end

    it "returns false for empty string" do
      expect(IsbnToolkit.valid?("")).to be false
    end

    it "returns false for random string" do
      expect(IsbnToolkit.valid?("not-an-isbn")).to be false
    end
  end

  describe ".parse" do
    it "returns an ISBN object" do
      isbn = IsbnToolkit.parse("9780132350884")
      expect(isbn).to be_a(IsbnToolkit::ISBN)
      expect(isbn.valid?).to be true
    end
  end

  describe ".lookup" do
    it "fetches metadata from Open Library" do
      stub_request(:get, /openlibrary.org/)
        .to_return(
          status: 200,
          body: {
            "ISBN:9780132350884" => {
              "title" => "Clean Code",
              "authors" => [{ "name" => "Robert C. Martin" }],
              "publishers" => [{ "name" => "Prentice Hall" }],
              "publish_date" => "2008",
              "number_of_pages" => 464,
              "cover" => { "large" => "https://example.com/cover.jpg" }
            }
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      book = IsbnToolkit.lookup("9780132350884")
      expect(book.found?).to be true
      expect(book.title).to eq("Clean Code")
      expect(book.authors).to include("Robert C. Martin")
    end

    it "returns empty result when not found" do
      stub_request(:get, /openlibrary.org/)
        .to_return(status: 200, body: "{}", headers: { "Content-Type" => "application/json" })

      book = IsbnToolkit.lookup("0000000000000")
      expect(book.found?).to be false
    end
  end
end
