# frozen_string_literal: true

module Lib
  class PdfTransactionAdapter < Lib::Parser
    AMOUNT_REGEX = /([+-])\s*\$\s*([\d,]+\.\d{2})/
    DATE_HEADING_REGEX = /\A(\d{1,2})\s*([A-Za-z]{3,9})\s*(\d{4})\z/
    DATE_SLASH_REGEX = %r{(\d{1,2})\/(\d{1,2})\/(\d{4})}

    def initialize(text)
      super()
      @text = text
    end

    def transactions
      statement_date = parse_slash_date(@text)

      transaction_text = transaction_section(@text)
      return [] if transaction_text.blank?

      lines = normalize_lines(transaction_text)
      build_transactions(lines, statement_date)
    end

    private

    def transaction_section(_text)
      raise NotImplementedError
    end

    def noise_line?(_line)
      raise NotImplementedError
    end

    def normalize_lines(text)
      text
        .split(/\r\n|\r|\n/)
        .map { |line| line.encode('UTF-8', invalid: :replace, undef: :replace, replace: ' ') }
        .map { |line| line.gsub(/[^\x20-\x7E]/, ' ') }
        .map { |line| line.gsub(/\s+/, ' ').strip }
        .reject(&:empty?)
    end

    def build_transactions(lines, statement_date = nil)
      transactions = []
      details = []
      current_date = nil

      lines.each do |line|
        statement_date ||= parse_slash_date(line)

        if line.casecmp('today').zero?
          append_trailing_details!(transactions, current_date, details)
          current_date = statement_date || Time.zone.today
          details = []
          next
        end

        if line.casecmp('yesterday').zero?
          append_trailing_details!(transactions, current_date, details)
          base = statement_date || Time.zone.today
          current_date = base - 1
          details = []
          next
        end

        parsed_date = parse_heading_date(line)
        if parsed_date
          append_trailing_details!(transactions, current_date, details)
          current_date = parsed_date
          details = []
          next
        end

        amount = extract_amount(line)
        if amount
          inline_memo = memo_without_amount(line)
          memo_parts = details.dup
          memo_parts << inline_memo unless inline_memo.empty? || reference_line?(inline_memo)
          memo = memo_parts.join(' ').strip
          details = []

          next if memo.empty? || current_date.nil?

          transaction = ImportedTransaction.new
          transaction.date = current_date
          transaction.memo = memo
          transaction.amount = amount
          transactions << transaction
          next
        end

        next if noise_line?(line)

        details << line
      end

      append_trailing_details!(transactions, current_date, details)
      transactions
    end

    def append_trailing_details!(transactions, current_date, details)
      return if details.empty? || transactions.empty? || current_date.nil?
      return unless transactions.last.date == current_date

      suffix = details.join(' ').strip
      return if suffix.empty?

      transactions.last.memo = [transactions.last.memo, suffix].join(' ').strip
      details.clear
    end

    def parse_heading_date(line)
      match = line.match(DATE_HEADING_REGEX)
      return nil unless match

      parse_date("#{match[1]} #{match[2]} #{match[3]}")
    rescue Date::Error
      nil
    end

    def parse_slash_date(line)
      match = line.match(DATE_SLASH_REGEX)
      return nil unless match

      Date.new(match[3].to_i, match[2].to_i, match[1].to_i)
    rescue Date::Error
      nil
    end

    def extract_amount(line)
      match = line.match(AMOUNT_REGEX)
      return nil unless match

      parse_amount("#{match[1]}#{match[2]}")
    end

    def memo_without_amount(line)
      line.gsub(AMOUNT_REGEX, '').gsub(/\s+/, ' ').strip
    end

    def reference_line?(line)
      line.match?(/\A[\d\s\.]+\z/)
    end
  end
end
