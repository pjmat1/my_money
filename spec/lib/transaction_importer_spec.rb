# frozen_string_literal: true

require 'rails_helper'

describe Lib::TransactionImporter do
  let(:account) { FactoryBot.create(:account) }
  let(:memo) { 'MEMO' }
  let(:date) { '2014-07-01' }
  let(:amount) { 333 }
  let(:file) { double 'file' } # rubocop:disable RSpec/VerifiedDoubles

  describe 'ofx file' do
    before do
      ofx_parser = instance_double Lib::OfxParser
      transaction = ImportedTransaction.new(memo:, date:, amount:)

      allow(file).to receive(:original_filename).and_return('file.ofx')
      allow(Lib::OfxParser).to receive(:new).with(file).and_return(ofx_parser)
      allow(ofx_parser).to receive(:transactions).and_return([transaction])
    end

    it 'returns the parsed transactions' do
      transactions = described_class.new(account, file).execute

      expect(transactions.length).to eq(1)
      expect(transactions[0].memo).to eq(memo)
      expect(transactions[0].date).to eq(Date.parse(date))
      expect(transactions[0].amount).to eq(amount)
      expect(transactions[0].category_id).to be_nil
      expect(transactions[0].subcategory_id).to be_nil
      expect(transactions[0].duplicate).to be_falsey
      expect(transactions[0].import).to be_truthy
    end

    it 'sets the transactions to duplicate if they already exist' do
      FactoryBot.create(:transaction, account:, memo:, date:, amount:)
      transactions = described_class.new(account, file).execute

      expect(transactions.length).to eq(1)
      expect(transactions[0].duplicate).to be_truthy
      expect(transactions[0].import).to be_falsey
    end

    it 'does not set to duplicate if matching transaction in a different account' do
      FactoryBot.create(:transaction, memo:, date:, amount:)
      transactions = described_class.new(account, file).execute

      expect(transactions.length).to eq(1)
      expect(transactions[0].duplicate).to be_falsey
      expect(transactions[0].import).to be_truthy
    end

    it 'sets category and subcategory for transactions which match a pattern' do
      category = FactoryBot.create(:category)
      subcategory = FactoryBot.create(:subcategory, category:)
      FactoryBot.create(:pattern, account:, match_text: memo, notes: 'New Note', category:,
                                  subcategory:)

      transactions = described_class.new(account, file).execute

      expect(transactions.length).to eq(1)
      expect(transactions[0].memo).to eq(memo)
      expect(transactions[0].date).to eq(Date.parse(date))
      expect(transactions[0].amount).to eq(amount)
      expect(transactions[0].category_id).to eq(category.id)
      expect(transactions[0].subcategory_id).to eq(subcategory.id)
      expect(transactions[0].duplicate).to be_falsey
      expect(transactions[0].import).to be_truthy
    end

    it 'routes uppercase OFX extensions to the OFX parser' do
      ofx_parser = instance_double Lib::OfxParser
      transaction = ImportedTransaction.new(memo:, date:, amount:)

      allow(file).to receive(:original_filename).and_return('file.OFX')
      allow(Lib::OfxParser).to receive(:new).with(file).and_return(ofx_parser)
      allow(ofx_parser).to receive(:transactions).and_return([transaction])

      transactions = described_class.new(account, file).execute

      expect(transactions.length).to eq(1)
      expect(transactions[0].memo).to eq(memo)
    end
  end

  describe 'csv file' do
    it 'returns the parsed transactions' do
      csv_parser = instance_double Lib::CsvParser
      transaction = ImportedTransaction.new(memo:, date:, amount:)

      allow(file).to receive(:original_filename).and_return('file.csv')
      allow(Lib::CsvParser).to receive(:new).with(file).and_return(csv_parser)
      allow(csv_parser).to receive(:transactions).and_return([transaction])

      transactions = described_class.new(account, file).execute

      expect(transactions.length).to eq(1)
      expect(transactions[0].memo).to eq(memo)
      expect(transactions[0].date).to eq(Date.parse(date))
      expect(transactions[0].amount).to eq(amount)
      expect(transactions[0].duplicate).to be_falsey
      expect(transactions[0].import).to be_truthy
    end
  end

  describe 'pdf file' do
    it 'returns the parsed transactions' do
      pdf_parser = instance_double Lib::PdfParser
      transaction = ImportedTransaction.new(memo:, date:, amount:)

      allow(file).to receive(:original_filename).and_return('file.pdf')
      allow(Lib::PdfParser).to receive(:new).with(file).and_return(pdf_parser)
      allow(pdf_parser).to receive(:transactions).and_return([transaction])

      transactions = described_class.new(account, file).execute

      expect(transactions.length).to eq(1)
      expect(transactions[0].memo).to eq(memo)
      expect(transactions[0].date).to eq(Date.parse(date))
      expect(transactions[0].amount).to eq(amount)
      expect(transactions[0].duplicate).to be_falsey
      expect(transactions[0].import).to be_truthy
    end

    it 'routes uppercase PDF extensions to the PDF parser' do
      pdf_parser = instance_double Lib::PdfParser
      transaction = ImportedTransaction.new(memo:, date:, amount:)

      allow(file).to receive(:original_filename).and_return('file.PDF')
      allow(Lib::PdfParser).to receive(:new).with(file).and_return(pdf_parser)
      allow(pdf_parser).to receive(:transactions).and_return([transaction])

      transactions = described_class.new(account, file).execute

      expect(transactions.length).to eq(1)
      expect(transactions[0].memo).to eq(memo)
    end
  end
end
