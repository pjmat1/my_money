# frozen_string_literal: true

require 'csv'

module Lib
  class CsvParser < Lib::Parser
    PENDING_PURCHASE_MARKER = 'PURCHASE AUTHORISATION'

    def initialize(file)
      super()
      @file = file
    end

    def transactions
      @transactions ||= parse
    end

    private

    def parse
      @file.rewind if @file.respond_to?(:rewind)
      csv = CSV.parse(@file.read, headers: true, header_converters: :symbol)
      return [] if csv.empty?

      filtered_rows = csv.reject { |row| pending_purchase_authorisation?(row) }

      adapter_for(csv.headers).new(filtered_rows).transactions
    end

    def pending_purchase_authorisation?(row)
      row.fields.any? { |value| value.to_s.upcase.include?(PENDING_PURCHASE_MARKER) }
    end

    def adapter_for(headers)
      adapters.find { |adapter_class| adapter_class.matches_headers?(headers) } || Lib::LegacyCsvTransactionAdapter
    end

    def adapters
      [
        Lib::PeopleFirstBankCsvAdapter,
        Lib::LegacyCsvTransactionAdapter
      ]
    end
  end
end
