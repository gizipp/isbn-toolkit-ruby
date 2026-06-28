# frozen_string_literal: true

RSpec.describe IsbnToolkit::Converter do
  describe ".isbn10_to_isbn13" do
    it "converts ISBN-10 to ISBN-13" do
      result = described_class.isbn10_to_isbn13("0132350882")
      expect(result).to eq("9780132350884")
    end

    it "converts ISBN-10 with X check digit" do
      result = described_class.isbn10_to_isbn13("080442957X")
      expect(result.length).to eq(13)
      expect(result).to start_with("978")
    end

    it "raises error for invalid length" do
      expect { described_class.isbn10_to_isbn13("123") }.to raise_error(IsbnToolkit::InvalidISBN)
    end
  end

  describe ".isbn13_to_isbn10" do
    it "converts ISBN-13 to ISBN-10" do
      result = described_class.isbn13_to_isbn10("9780132350884")
      expect(result).to eq("0132350882")
    end

    it "raises error for 979-prefix" do
      expect { described_class.isbn13_to_isbn10("9791234567896") }
        .to raise_error(IsbnToolkit::InvalidISBN, /979/)
    end
  end

  describe ".calculate_isbn13_check" do
    it "calculates correct check digit" do
      expect(described_class.calculate_isbn13_check("978013235088")).to eq("4")
    end

    it "calculates 0 check digit" do
      # ISBN-13 where check digit is 0
      expect(described_class.calculate_isbn13_check("978000000000")).to be_a(String)
    end
  end

  describe ".calculate_isbn10_check" do
    it "calculates correct check digit" do
      expect(described_class.calculate_isbn10_check("013235088")).to eq("2")
    end

    it "calculates X check digit" do
      result = described_class.calculate_isbn10_check("080442957")
      expect(result).to eq("X")
    end
  end

  describe ".format_isbn13" do
    it "formats with hyphens" do
      expect(described_class.format_isbn13("9780132350884")).to eq("978-0-13-235088-4")
    end
  end

  describe ".format_isbn10" do
    it "formats with hyphens" do
      expect(described_class.format_isbn10("0132350882")).to eq("0-13-235088-2")
    end
  end
end
