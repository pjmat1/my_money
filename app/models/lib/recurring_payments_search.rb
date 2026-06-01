# frozen_string_literal: true

module Lib
  class RecurringPaymentsSearch < Search
    MINIMUM_MONTHS = 3

    def initialize(attrs = {})
      super()
      @date_range = attrs.fetch(:date_range, Lib::Last6MonthsDateRange.new)
    end

    def report
      grouped_candidates
        .select { |candidate| candidate[:months_matched] >= MINIMUM_MONTHS }
        .sort_by { |candidate| [-candidate[:months_matched], -candidate[:amount].abs, candidate[:merchant]] }
    end

    private

    def transaction_query
      Transaction
        .for_banking_accounts
        .search_by_date(@date_range)
        .where(matching_transaction: nil)
        .where('amount < 0')
        .reverse_date_order
    end

    def grouped_candidates
      groups = transactions.group_by do |transaction|
        [normalized_merchant(transaction), transaction.amount]
      end

      groups.map do |(merchant_key, amount), grouped_transactions|
        month_counts = grouped_transactions.each_with_object(Hash.new(0)) do |transaction, counts|
          counts[transaction.date.strftime('%Y-%m')] += 1
        end

        {
          merchant: display_merchant(grouped_transactions),
          merchant_key: merchant_key,
          amount: amount,
          months_matched: month_counts.keys.length,
          occurrence_count: grouped_transactions.length,
          first_date: grouped_transactions.min_by(&:date).date.to_s,
          last_date: grouped_transactions.max_by(&:date).date.to_s,
          monthly_occurrences: month_counts.sort.to_h,
          transactions: grouped_transactions
        }
      end
    end

    def normalized_merchant(transaction)
      merchant_text(transaction)
        .downcase
        .gsub(/[^a-z0-9\s]/, ' ')
        .gsub(/\s+/, ' ')
        .strip
    end

    def display_merchant(grouped_transactions)
      merchant_counts = grouped_transactions.each_with_object(Hash.new(0)) do |transaction, counts|
        merchant = merchant_text(transaction).strip
        counts[merchant] += 1
      end

      merchant_counts.max_by { |merchant, count| [count, merchant.length] }&.first || ''
    end

    def merchant_text(transaction)
      return transaction.memo.to_s if transaction.memo.present?
      return transaction.notes.to_s if transaction.notes.present?

      ''
    end
  end
end
