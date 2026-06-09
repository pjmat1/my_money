# frozen_string_literal: true

require 'rails_helper'

describe Lib::PdfParser do
  let(:file) { StringIO.new('%PDF-FAKE') }

  describe '#transactions' do
    it 'delegates supported statements to the People First Bank adapter' do
      parser = described_class.new(file)
      adapter = instance_double(Lib::PeopleFirstBankPdfAdapter, transactions: ['txn'])
      allow(parser).to receive(:extract_text).and_return('09/06/2026 Accounts - Retail Banking peoplefirstbank')
      allow(Lib::PeopleFirstBankPdfAdapter).to receive(:matches?).and_return(true)
      allow(Lib::PeopleFirstBankPdfAdapter).to receive(:new).with('09/06/2026 Accounts - Retail Banking peoplefirstbank').and_return(adapter)

      expect(parser.transactions).to eq(['txn'])
    end
  end

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
    expect(transactions[0].memo).to eq('Osko TfrTo Samantha Matthews Dinner Refund')
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

  it 'parses lines where memo and amount are on the same line' do
    parser = described_class.new(file)
    allow(parser).to receive(:extract_text).and_return(<<~TEXT)
      09/06/2026, 19:48 Accounts - Retail Banking
      2 results found
      14 May2026
      IbTfr102893244To 102893246 -$10,000.00
      Payroll Credit CultureAmp Pty
      492484 000622 +$11,486.91
      all transactions have been loaded.
    TEXT

    transactions = parser.transactions

    expect(transactions.length).to eq(2)
    expect(transactions[0].date).to eq(Date.new(2026, 5, 14))
    expect(transactions[0].memo).to eq('IbTfr102893244To 102893246')
    expect(transactions[0].amount).to eq(-1_000_000)

    expect(transactions[1].date).to eq(Date.new(2026, 5, 14))
    expect(transactions[1].memo).to eq('Payroll Credit CultureAmp Pty')
    expect(transactions[1].amount).to eq(1_148_691)
  end

  it 'parses statements that say singular result found' do
    parser = described_class.new(file)
    allow(parser).to receive(:extract_text).and_return(<<~TEXT)
      09/06/2026, 20:14 Loans - Accounts - Accounts - Retail Banking
      1 result found
      31 May2026
      Interest -$2,014.14
      all transactions have been loaded.
    TEXT

    transactions = parser.transactions

    expect(transactions.length).to eq(1)
    expect(transactions[0].date).to eq(Date.new(2026, 5, 31))
    expect(transactions[0].memo).to eq('Interest')
    expect(transactions[0].amount).to eq(-201_414)
  end
end
