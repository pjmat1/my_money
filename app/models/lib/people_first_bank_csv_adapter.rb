# frozen_string_literal: true

module Lib
  class PeopleFirstBankCsvAdapter < Lib::CsvTransactionAdapter
    def self.matches_headers?(headers)
      symbols = headers.compact.map(&:to_sym)
      symbols.include?(:date) &&
        symbols.include?(:amount) &&
        symbols.include?(:transaction_details)
    end

    private

    def transaction_date(row)
      parse_date(row[:date])
    rescue Date::Error, TypeError
      nil
    end

    def transaction_memo(row)
      [
        row[:transaction_details],
        row[:merchant_name],
        row[:transaction_type]
      ].map { |value| value.to_s.strip }.find(&:present?).to_s
    end

    def transaction_amount(row)
      value = row[:amount].to_s.strip
      return nil if value.empty?

      parse_amount(value)
    end
  end
end
