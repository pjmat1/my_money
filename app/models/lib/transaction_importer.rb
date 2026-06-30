# frozen_string_literal: true

module Lib
  class TransactionImporter
    NON_PRINTING_REGEX = /[\u200B-\u200D\uFEFF]/.freeze
    MEMO_TOKEN_REGEX = /\A[[:alnum:]\-.]+\z/.freeze
    NAME_SUFFIX_TOKEN_REGEX = /\A[[:alpha:]'\-]+\z/.freeze

    def initialize(account, data_file)
      @account = account
      @data_file = data_file
    end

    def execute
      @transactions = parser.transactions

      @transactions.each do |t|
        build_transaction(t)
      end

      @transactions
    end

    def parser
      case File.extname(@data_file.original_filename).downcase
      when '.ofx'
        Lib::OfxParser.new(@data_file)
      when '.pdf'
        Lib::PdfParser.new(@data_file)
      else
        Lib::CsvParser.new(@data_file)
      end
    end

    def build_transaction(txn)
      txn.account = @account
      txn.duplicate = duplicate_transaction?(txn)
      txn.import = !txn.duplicate
      apply_patterns(txn)
    end

    def apply_patterns(transaction)
      return if transaction.memo.blank?

      normalized_memo = normalize_memo(transaction.memo)

      Pattern.where(account_id: @account.id).find_each do |pattern|
        normalized_match_text = normalize_memo(pattern.match_text)
        next if normalized_match_text.blank?
        next unless normalized_memo.include?(normalized_match_text)

        allocate_transaction(transaction, pattern)
        break
      end
    end

    def allocate_transaction(transaction, pattern)
      transaction.category_id = pattern.category_id
      transaction.subcategory_id = pattern.subcategory_id
      transaction.notes = pattern.notes
    end

    def duplicate_transaction?(txn)
      exact_scope = Transaction.where(account: @account, date: txn.date, amount: txn.amount)
      return exact_scope.exists?(memo: nil) if txn.memo.nil?

      normalized_memo = normalize_memo(txn.memo)
      exact_scope.where.not(memo: nil).any? do |existing|
        memo_equivalent_for_duplicate?(normalize_memo(existing.memo), normalized_memo)
      end
    end

    def memo_equivalent_for_duplicate?(left_memo, right_memo)
      return true if left_memo == right_memo

      short_memo, long_memo = [left_memo, right_memo].sort_by(&:length)
      return false unless long_memo.start_with?(short_memo)

      suffix = long_memo[short_memo.length..]&.strip
      reference_suffix?(suffix) || short_name_suffix?(suffix)
    end

    def reference_suffix?(suffix)
      return false if suffix.blank?

      tokens = suffix.split
      return false if tokens.empty?
      return false unless tokens.all? { |token| token.match?(MEMO_TOKEN_REGEX) && token.match?(/\d/) }

      suffix.count('0-9') >= 4
    end

    def short_name_suffix?(suffix)
      return false if suffix.blank?

      tokens = suffix.split
      return false if tokens.empty? || tokens.length > 2
      return false unless tokens.all? { |token| token.match?(NAME_SUFFIX_TOKEN_REGEX) }

      suffix.length <= 24
    end

    def normalize_memo(value)
      value.to_s
        .encode('UTF-8', invalid: :replace, undef: :replace, replace: ' ')
        .unicode_normalize(:nfkc)
        .gsub(/\r\n|\r|\n/, ' ')
        .gsub(NON_PRINTING_REGEX, '')
        .gsub(/\s+/, ' ')
        .strip
        .downcase
    end
  end
end
