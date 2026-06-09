# frozen_string_literal: true

module Lib
  class PeopleFirstBankPdfAdapter < Lib::PdfTransactionAdapter
    START_MARKER_REGEX = /\b\d+\s+result(?:s)?\s+found\b/i
    END_MARKER_REGEX = /all\s+transactions\s+have\s+been\s+loaded/i

    def self.matches?(text)
      normalized = text.to_s.downcase
      normalized.include?('retail banking') || normalized.match?(/people.*bank/)
    end

    private

    def transaction_section(text)
      start_match = text.match(START_MARKER_REGEX)
      return nil unless start_match

      end_match = text.match(END_MARKER_REGEX)
      return nil unless end_match

      return nil if end_match.begin(0) <= start_match.end(0)

      text[start_match.end(0)...end_match.begin(0)]
    end

    def noise_line?(line)
      line.match?(%r{\Ahttps?://}i) ||
        line.match?(/\A\d{1,2}\/\d{1,2}\/\d{4},\s*\d{1,2}:\d{2}\s+accounts\s+-\s+retail\s+banking\z/i) ||
        line.match?(/\Aaccounts\s+-\s+retail\s+banking\z/i) ||
        line.match?(/\A(backto\s+accounts|transactions|account\s+details|quick\s+actions|quick\s+links)\z/i) ||
        line.match?(/\A(apply|close|clear\s*filters|search|filters)\z/i)
    end
  end
end
