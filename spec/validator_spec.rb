# frozen_string_literal: true

RSpec.describe IsbnToolkit::Validator do
  describe ".isbn13_valid?" do
    it "returns true for valid ISBN-13" do
      expect(described_class.isbn13_valid?("9780132350884")).to be true
    end

    it "returns false for invalid checksum" do
      expect(described_class.isbn13_valid?("9780132350885")).to be false
    end

    it "returns false for non-13-digit string" do
      expect(described_class.isbn13_valid?("12345")).to be false
    end

    it "returns false for non-numeric string" do
      expect(described_class.isbn13_valid?("abcdefghijklm")).to be false
    end
  end

  describe ".isbn10_valid?" do
    it "returns true for valid ISBN-10" do
      expect(described_class.isbn10_valid?("0132350882")).to be true
    end

    it "returns true for ISBN-10 with X check" do
      expect(described_class.isbn10_valid?("080442957X")).to be true
    end

    it "returns false for invalid checksum" do
      expect(described_class.isbn10_valid?("0132350883")).to be false
    end

    it "returns false for non-10-digit string" do
      expect(described_class.isbn10_valid?("12345")).to be false
    end
  end

  describe ".valid?" do
    it "auto-detects ISBN-13" do
      expect(described_class.valid?("9780132350884")).to be true
    end

    it "auto-detects ISBN-10" do
      expect(described_class.valid?("0132350882")).to be true
    end

    it "returns false for unknown format" do
      expect(described_class.valid?("12345")).to be false
    end
  end
end
