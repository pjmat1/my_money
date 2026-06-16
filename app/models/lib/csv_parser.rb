# frozen_string_literal: true

require 'csv'

module Lib
  class CsvParser < Lib::Parser
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

      adapter_for(csv.headers).new(csv).transactions
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
