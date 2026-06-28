# frozen_string_literal: true

RSpec.describe IsbnToolkit::ISBN do
  describe "#valid?" do
    context "with ISBN-13" do
      it "returns true for valid ISBN-13" do
        expect(described_class.new("9780132350884").valid?).to be true
      end

      it "returns true for valid ISBN-13 with hyphens" do
        expect(described_class.new("978-0-13-235088-4").valid?).to be true
      end

      it "returns false for ISBN-13 with wrong check digit" do
        expect(described_class.new("9780132350885").valid?).to be false
      end

      it "returns false for 13 random digits" do
        expect(described_class.new("1234567890123").valid?).to be false
      end
    end

    context "with ISBN-10" do
      it "returns true for valid ISBN-10" do
        expect(described_class.new("0132350882").valid?).to be true
      end

      it "returns true for valid ISBN-10 with X check digit" do
        expect(described_class.new("080442957X").valid?).to be true
      end

      it "returns false for ISBN-10 with wrong check digit" do
        expect(described_class.new("0132350883").valid?).to be false
      end
    end

    context "with invalid input" do
      it "raises InvalidISBN for nil" do
        expect { described_class.new(nil) }.to raise_error(IsbnToolkit::InvalidISBN)
      end

      it "raises InvalidISBN for empty string" do
        expect { described_class.new("") }.to raise_error(IsbnToolkit::InvalidISBN)
      end

      it "returns false for wrong length" do
        expect(described_class.new("12345").valid?).to be false
      end
    end
  end

  describe "#isbn13?" do
    it "returns true for 13-digit ISBN" do
      expect(described_class.new("9780132350884").isbn13?).to be true
    end

    it "returns false for 10-digit ISBN" do
      expect(described_class.new("0132350882").isbn13?).to be false
    end
  end

  describe "#isbn10?" do
    it "returns true for 10-digit ISBN" do
      expect(described_class.new("0132350882").isbn10?).to be true
    end

    it "returns false for 13-digit ISBN" do
      expect(described_class.new("9780132350884").isbn10?).to be false
    end
  end

  describe "#to_isbn13" do
    it "converts ISBN-10 to ISBN-13" do
      isbn = described_class.new("0132350882")
      expect(isbn.to_isbn13).to eq("9780132350884")
    end

    it "returns self if already ISBN-13" do
      isbn = described_class.new("9780132350884")
      expect(isbn.to_isbn13).to eq("9780132350884")
    end
  end

  describe "#to_isbn10" do
    it "converts ISBN-13 to ISBN-10" do
      isbn = described_class.new("9780132350884")
      expect(isbn.to_isbn10).to eq("0132350882")
    end

    it "returns self if already ISBN-10" do
      isbn = described_class.new("0132350882")
      expect(isbn.to_isbn10).to eq("0132350882")
    end

    it "raises error for 979-prefix ISBN-13" do
      # 979 prefix doesn't have ISBN-10 equivalent
      isbn = described_class.new("9791234567896") # valid checksum
      expect { isbn.to_isbn10 }.to raise_error(IsbnToolkit::InvalidISBN)
    end
  end

  describe "#formatted" do
    it "formats ISBN-13 with hyphens" do
      isbn = described_class.new("9780132350884")
      expect(isbn.formatted).to eq("978-0-13-235088-4")
    end
  end

  describe "#to_s" do
    it "returns clean digits" do
      isbn = described_class.new("978-0-13-235088-4")
      expect(isbn.to_s).to eq("9780132350884")
    end
  end

  describe "#==" do
    it "considers ISBN-10 and ISBN-13 equivalent" do
      isbn10 = described_class.new("0132350882")
      isbn13 = described_class.new("9780132350884")
      expect(isbn10).to eq(isbn13)
    end
  end

  describe "#inspect" do
    it "shows useful debug info" do
      isbn = described_class.new("9780132350884")
      expect(isbn.inspect).to include("9780132350884")
      expect(isbn.inspect).to include("valid=true")
    end
  end
end
