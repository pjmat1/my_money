# frozen_string_literal: true

require 'pdf/reader'

module Lib
  class PdfParser < Lib::Parser
    START_MARKER_REGEX = /\b\d+\s+results\s+found\b/i
    END_MARKER_REGEX = /all\s+transactions\s+have\s+been\s+loaded/i
    AMOUNT_REGEX = /([+-])\s*\$\s*([\d,]+\.\d{2})/
    DATE_HEADING_REGEX = /\A(\d{1,2})\s*([A-Za-z]{3,9})\s*(\d{4})\z/
    DATE_SLASH_REGEX = %r{\A(\d{1,2})/(\d{1,2})/(\d{4})\z}

    def initialize(file)
      super()
      @file = file
    end

    def transactions
      @transactions ||= parse
    end

    private

    def parse
      text = extract_text
      return [] if text.blank?

      transaction_text = transaction_section(text)
      return [] if transaction_text.blank?

      lines = normalize_lines(transaction_text)
      build_transactions(lines)
    end

    def extract_text
      source = pdf_source
      source.rewind if source.respond_to?(:rewind)
      PDF::Reader.new(source).pages.map(&:text).join("\n")
    end

    def pdf_source
      return @file.tempfile if @file.respond_to?(:tempfile) && @file.tempfile
      return @file.path if @file.respond_to?(:path) && @file.path

      @file
    end

    def transaction_section(text)
      start_match = text.match(START_MARKER_REGEX)
      return nil unless start_match

      end_match = text.match(END_MARKER_REGEX)
      return nil unless end_match

      return nil if end_match.begin(0) <= start_match.end(0)

      text[start_match.end(0)...end_match.begin(0)]
    end

    def normalize_lines(text)
      text
        .split(/\r\n|\r|\n/)
        .map { |line| line.encode('UTF-8', invalid: :replace, undef: :replace, replace: ' ') }
        .map { |line| line.gsub(/[^\x20-\x7E]/, ' ') }
        .map { |line| line.gsub(/\s+/, ' ').strip }
        .reject(&:empty?)
    end

    def build_transactions(lines)
      transactions = []
      details = []
      current_date = nil
      statement_date = nil

      lines.each do |line|
        statement_date ||= parse_slash_date(line)

        if line.casecmp('today').zero?
          current_date = statement_date || Time.zone.today
          details = []
          next
        end

        if line.casecmp('yesterday').zero?
          base = statement_date || Time.zone.today
          current_date = base - 1
          details = []
          next
        end

        parsed_date = parse_heading_date(line)
        if parsed_date
          current_date = parsed_date
          details = []
          next
        end

        amount = extract_amount(line)
        if amount
          memo = details.join(' ').strip
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

      transactions
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

    def noise_line?(line)
      line.match?(%r{\Ahttps?://}i) ||
        line.match?(/\A(backto\s+accounts|transactions|account\s+details|quick\s+actions|quick\s+links)\z/i) ||
        line.match?(/\A(apply|close|clear\s*filters|search|filters)\z/i)
    end
  end
end
