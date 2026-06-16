# frozen_string_literal: true

module Lib
  class LegacyCsvTransactionAdapter < Lib::CsvTransactionAdapter
    def self.matches_headers?(headers)
      symbols = headers.compact.map(&:to_sym)
      symbols.include?(:date) &&
        symbols.include?(:description) &&
        (symbols.include?(:debit) || symbols.include?(:credit))
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
      parse_debit(row[:debit]) || parse_credit(row[:credit])
    end
  end
end
