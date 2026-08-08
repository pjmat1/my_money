# frozen_string_literal: true

require 'csv'

module Lib
  class CsvParser < Lib::Parser
    PENDING_PURCHASE_MARKER = 'PURCHASE AUTHORISATION'
    BYTE_ORDER_MARK = "\uFEFF"

    def initialize(file)
      super()
      @file = file
    end

    def transactions
      @transactions ||= parse
    end

    private

    def parse
      csv = CSV.parse(content, headers: true, header_converters: :symbol)
      return [] if csv.empty?

      filtered_rows = csv.reject { |row| pending_purchase_authorisation?(row) }

      adapter_for(csv.headers).new(filtered_rows).transactions
    end

    # Uploaded files are read as binary, so tag the bytes as UTF-8, drop any
    # invalid ones and strip a leading byte order mark before parsing.
    def content
      @file.rewind if @file.respond_to?(:rewind)

      @file.read
           .to_s
           .dup
           .force_encoding(Encoding::UTF_8)
           .scrub('')
           .delete_prefix(BYTE_ORDER_MARK)
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
        Lib::LegacyCsvTransactionAdapter,
        Lib::SignedAmountCsvAdapter
      ]
    end
  end
end
