# frozen_string_literal: true

module Lib
  # Handles CSV exports that use a single signed amount column alongside a
  # description, rather than separate debit and credit columns.
  class SignedAmountCsvAdapter < Lib::CsvTransactionAdapter
    def self.matches_headers?(headers)
      symbols = headers.compact.map(&:to_sym)
      symbols.include?(:date) &&
        symbols.include?(:description) &&
        symbols.include?(:amount)
    end

    private

    def transaction_date(row)
      parse_date(row[:date])
    rescue Date::Error, TypeError
      nil
    end

    def transaction_memo(row)
      row[:description].to_s.strip
    end

    def transaction_amount(row)
      value = row[:amount].to_s.strip
      return nil if value.empty?

      parse_amount(value)
    end
  end
end
