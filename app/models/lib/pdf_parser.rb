# frozen_string_literal: true

require 'pdf/reader'

module Lib
  class PdfParser < Lib::Parser
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

      adapter = adapter_for(text)
      return [] unless adapter

      adapter.transactions
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

    def adapter_for(text)
      adapters.find { |adapter_class| adapter_class.matches?(text) }&.new(text)
    end

    def adapters
      [Lib::PeopleFirstBankPdfAdapter]
    end
  end
end
