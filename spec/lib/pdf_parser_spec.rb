# frozen_string_literal: true

require 'rails_helper'

describe Lib::PdfParser do
  let(:file) { StringIO.new('%PDF-FAKE') }

  describe '#extract_text' do
    it 'uses tempfile when file behaves like ActionDispatch::Http::UploadedFile' do
      tempfile = StringIO.new('%PDF-FAKE')
      uploaded_file = instance_double('ActionDispatch::Http::UploadedFile', tempfile: tempfile)
      parser = described_class.new(uploaded_file)
      page = instance_double('PDF::Reader::Page', text: 'page one')
      reader = instance_double('PDF::Reader', pages: [page])

      expect(PDF::Reader).to receive(:new).with(tempfile).and_return(reader)

      expect(parser.send(:extract_text)).to eq('page one')
    end

    it 'uses path when file only exposes a path' do
      path_file = instance_double('PathFile', path: '/tmp/test.pdf')
      parser = described_class.new(path_file)
      page = instance_double('PDF::Reader::Page', text: 'page one')
      reader = instance_double('PDF::Reader', pages: [page])

      expect(PDF::Reader).to receive(:new).with('/tmp/test.pdf').and_return(reader)

      expect(parser.send(:extract_text)).to eq('page one')
    end
  end

  it 'returns transactions between the results and loaded markers' do
    parser = described_class.new(file)
    allow(parser).to receive(:extract_text).and_return(<<~TEXT)
      01/06/2026, 20:29 Accounts - Retail Banking
      7 results found
      Yesterday
      Osko TfrTo Samantha Matthews
      -$160.00
      Dinner Refund

      29 May2026
      Osko Direct Credit Osko Paul Matthews
      +$3,820.00

      14 May2026
      Payroll Credit CultureAmp Pty
      +$11,486.91
      all transactions have been loaded.
      Quick links
    TEXT

    transactions = parser.transactions

    expect(transactions.length).to eq(3)

    expect(transactions[0].date).to eq(Date.new(2026, 5, 31))
    expect(transactions[0].memo).to eq('Osko TfrTo Samantha Matthews')
    expect(transactions[0].amount).to eq(-16_000)

    expect(transactions[1].date).to eq(Date.new(2026, 5, 29))
    expect(transactions[1].memo).to eq('Osko Direct Credit Osko Paul Matthews')
    expect(transactions[1].amount).to eq(382_000)

    expect(transactions[2].date).to eq(Date.new(2026, 5, 14))
    expect(transactions[2].memo).to eq('Payroll Credit CultureAmp Pty')
    expect(transactions[2].amount).to eq(1_148_691)
  end

  it 'returns an empty array when the section markers are missing' do
    parser = described_class.new(file)
    allow(parser).to receive(:extract_text).and_return(<<~TEXT)
      Transactions
      Osko TfrTo Samantha Matthews
      -$160.00
    TEXT

    expect(parser.transactions).to eq([])
  end

  it 'returns an empty array when the end marker appears before the start marker' do
    parser = described_class.new(file)
    allow(parser).to receive(:extract_text).and_return(<<~TEXT)
      all transactions have been loaded.
      7 results found
      Yesterday
      Coffee
      -$5.00
    TEXT

    expect(parser.transactions).to eq([])
  end

  it 'uses Time.zone.today for Today and Yesterday headings when statement date is absent' do
    parser = described_class.new(file)
    allow(Time.zone).to receive(:today).and_return(Date.new(2026, 6, 1))
    allow(parser).to receive(:extract_text).and_return(<<~TEXT)
      2 results found
      Today
      Coffee Shop
      -$10.00
      Yesterday
      Fuel Station
      -$20.00
      all transactions have been loaded.
    TEXT

    transactions = parser.transactions

    expect(transactions.length).to eq(2)
    expect(transactions[0].date).to eq(Date.new(2026, 6, 1))
    expect(transactions[0].memo).to eq('Coffee Shop')
    expect(transactions[0].amount).to eq(-1000)
    expect(transactions[1].date).to eq(Date.new(2026, 5, 31))
    expect(transactions[1].memo).to eq('Fuel Station')
    expect(transactions[1].amount).to eq(-2000)
  end
end
