# 📚 isbn_toolkit

[![Gem Version](https://badge.fury.io/rb/isbn_toolkit.svg)](https://badge.fury.io/rb/isbn_toolkit)
[![CI](https://github.com/gizipp/isbn-toolkit-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/gizipp/isbn-toolkit-ruby/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

All-in-one ISBN toolkit for Ruby — validate, convert, and lookup book metadata.

## Installation

```ruby
# Gemfile
gem "isbn_toolkit"
```

```
$ bundle install
```

Or install directly:

```
$ gem install isbn_toolkit
```

## Quick Start

```ruby
require "isbn_toolkit"

# Validate
IsbnToolkit.valid?("978-0-13-235088-4")  # => true
IsbnToolkit.valid?("1234567890")          # => false

# Parse
isbn = IsbnToolkit.parse("978-0-13-235088-4")
isbn.valid?     # => true
isbn.isbn13      # => "9780132350884"
isbn.isbn10      # => "0132350882"
isbn.formatted   # => "978-0-13-235088-4"

# Convert
isbn = IsbnToolkit.parse("0132350882")
isbn.to_isbn13   # => "9780132350884"

# Lookup metadata
book = IsbnToolkit.lookup("9780132350884")
book.title       # => "Clean Code"
book.authors     # => ["Robert C. Martin"]
book.publisher   # => "Prentice Hall"
book.cover       # => "https://..."
book.found?      # => true
```

## Features

### ✅ Validate ISBNs

```ruby
isbn = IsbnToolkit::ISBN.new("9780132350884")
isbn.valid?    # => true
isbn.isbn13?   # => true
isbn.isbn10?   # => false

# ISBN-10 with X check digit
isbn = IsbnToolkit::ISBN.new("080442957X")
isbn.valid?    # => true
```

### 🔄 Convert Between Formats

```ruby
isbn = IsbnToolkit::ISBN.new("0132350882")

isbn.to_isbn13   # => "9780132350884"
isbn.to_isbn10   # => "0132350882"
isbn.to_ean13    # => "9780132350884"
isbn.formatted   # => "978-0-13-235088-4"

# Direct conversion
IsbnToolkit::Converter.isbn10_to_isbn13("0132350882")  # => "9780132350884"
IsbnToolkit::Converter.isbn13_to_isbn10("9780132350884")  # => "0132350882"
```

### 📖 Lookup Book Metadata

```ruby
# From Open Library (default, free, no API key)
book = IsbnToolkit.lookup("9780132350884")
book.title       # => "Clean Code"
book.authors     # => ["Robert C. Martin"]
book.publisher   # => "Prentice Hall"
book.pages       # => 464

# From Google Books
book = IsbnToolkit.lookup("9780132350884", source: :google_books)
book.description # => "Even bad code can function..."
```

### 🛡️ ActiveRecord Validation

```ruby
class Book < ActiveRecord::Base
  validates :isbn, isbn: true                          # accepts any valid ISBN
  validates :isbn, isbn: { format: :isbn13 }           # ISBN-13 only
  validates :isbn, isbn: { format: :isbn10 }           # ISBN-10 only
end
```

## ISBN Formats Explained

| Format | Length | Example | Check |
|--------|--------|---------|-------|
| ISBN-10 | 10 digits | `0132350882` | Mod 11 |
| ISBN-13 | 13 digits | `9780132350884` | Mod 10 |
| EAN-13 | 13 digits | `9780132350884` | Same as ISBN-13 |

- All modern books use ISBN-13
- ISBN-10 is legacy but still common in older systems
- Only `978`-prefix ISBNs can convert to ISBN-10
- `979`-prefix ISBNs are ISBN-13 only

## Development

```bash
git clone https://github.com/gizipp/isbn-toolkit-ruby.git
cd isbn-toolkit-ruby
bin/setup
bin/rspec
```

## Related

- [isbn_toolkit](https://github.com/gizipp/isbn_toolkit) — JavaScript/TypeScript version (npm)
- [isbn-toolkit-php](https://github.com/gizipp/isbn-toolkit-php) — PHP version (Composer)

## Contributing

Bug reports and pull requests welcome at [github.com/gizipp/isbn-toolkit-ruby](https://github.com/gizipp/isbn-toolkit-ruby).

## License

[MIT License](LICENSE.txt)
