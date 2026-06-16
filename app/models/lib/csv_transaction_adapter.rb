# frozen_string_literal: true

module Lib
  class CsvTransactionAdapter < Lib::Parser
    def initialize(rows)
      super()
      @rows = rows
    end

    def transactions
      @rows.each_with_object([]) do |row, list|
        transaction = build_transaction(row)
        list << transaction if transaction
      end
    end

    def self.matches_headers?(_headers)
      raise NotImplementedError
    end

    private

    def build_transaction(row)
      date = transaction_date(row)
      memo = transaction_memo(row)
      amount = transaction_amount(row)

      return nil if date.nil? || memo.blank? || amount.nil?

      transaction = ImportedTransaction.new
      transaction.date = date
      transaction.memo = memo
      transaction.amount = amount
      transaction
    end

    def transaction_date(_row)
      raise NotImplementedError
    end

    def transaction_memo(_row)
      raise NotImplementedError
    end

    def transaction_amount(_row)
      raise NotImplementedError
    end
  end
end
