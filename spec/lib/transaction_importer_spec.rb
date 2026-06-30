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

    it 'sets duplicate when existing memo differs only by carriage returns' do
      pdf_parser = instance_double Lib::PdfParser
      parsed_memo = "Osko Direct Credit Osko Paul\r\nMatthews"
      existing_memo = 'Osko Direct Credit Osko Paul Matthews'
      transaction = ImportedTransaction.new(memo: parsed_memo, date:, amount:)

      allow(file).to receive(:original_filename).and_return('file.pdf')
      allow(Lib::PdfParser).to receive(:new).with(file).and_return(pdf_parser)
      allow(pdf_parser).to receive(:transactions).and_return([transaction])

      FactoryBot.create(:transaction, account:, memo: existing_memo, date:, amount:)

      transactions = described_class.new(account, file).execute

      expect(transactions.length).to eq(1)
      expect(transactions[0].duplicate).to be_truthy
      expect(transactions[0].import).to be_falsey
    end

    it 'sets duplicate when existing memo has trailing reference tokens' do
      pdf_parser = instance_double Lib::PdfParser
      parsed_memo = 'Direct DebitAnz Credit Card'
      existing_memo = 'Direct DebitAnz Credit Card 024332 4564680122023046'
      transaction = ImportedTransaction.new(memo: parsed_memo, date:, amount:)

      allow(file).to receive(:original_filename).and_return('file.pdf')
      allow(Lib::PdfParser).to receive(:new).with(file).and_return(pdf_parser)
      allow(pdf_parser).to receive(:transactions).and_return([transaction])

      FactoryBot.create(:transaction, account:, memo: existing_memo, date:, amount:)

      transactions = described_class.new(account, file).execute

      expect(transactions.length).to eq(1)
      expect(transactions[0].duplicate).to be_truthy
      expect(transactions[0].import).to be_falsey
    end

    it 'handles ascii-8bit memo encoding without raising errors' do
      pdf_parser = instance_double Lib::PdfParser
      parsed_memo = "Direct DebitAnz Credit Card\xC2".b
      parsed_memo.force_encoding(Encoding::ASCII_8BIT)
      transaction = ImportedTransaction.new(memo: parsed_memo, date:, amount:)

      allow(file).to receive(:original_filename).and_return('file.pdf')
      allow(Lib::PdfParser).to receive(:new).with(file).and_return(pdf_parser)
      allow(pdf_parser).to receive(:transactions).and_return([transaction])

      expect { described_class.new(account, file).execute }.not_to raise_error
    end

    it 'sets duplicate when imported memo adds a wrapped surname' do
      pdf_parser = instance_double Lib::PdfParser
      parsed_memo = "Osko Direct Credit Osko Paul\nMatthews"
      existing_memo = 'Osko Direct Credit Osko Paul'
      transaction = ImportedTransaction.new(memo: parsed_memo, date:, amount:)

      allow(file).to receive(:original_filename).and_return('file.pdf')
      allow(Lib::PdfParser).to receive(:new).with(file).and_return(pdf_parser)
      allow(pdf_parser).to receive(:transactions).and_return([transaction])

      FactoryBot.create(:transaction, account:, memo: existing_memo, date:, amount:)

      transactions = described_class.new(account, file).execute

      expect(transactions.length).to eq(1)
      expect(transactions[0].duplicate).to be_truthy
      expect(transactions[0].import).to be_falsey
    end

    it 'applies account pattern when memo spans lines' do
      pdf_parser = instance_double Lib::PdfParser
      wrapped_memo = "Osko Direct Credit Osko Paul\nMatthews"
      transaction = ImportedTransaction.new(memo: wrapped_memo, date:, amount:)
      category = FactoryBot.create(:category)
      subcategory = FactoryBot.create(:subcategory, category:)

      allow(file).to receive(:original_filename).and_return('file.pdf')
      allow(Lib::PdfParser).to receive(:new).with(file).and_return(pdf_parser)
      allow(pdf_parser).to receive(:transactions).and_return([transaction])

      FactoryBot.create(:pattern,
                        account:,
                        match_text: 'Osko Direct Credit Osko Paul Matthews',
                        category:,
                        subcategory:,
                        notes: 'Matched wrapped memo')

      other_account = FactoryBot.create(:account)
      other_category = FactoryBot.create(:category)
      FactoryBot.create(:pattern,
                        account: other_account,
                        match_text: 'Osko Direct Credit Osko Paul Matthews',
                        category: other_category,
                        notes: 'Should not be used')

      transactions = described_class.new(account, file).execute

      expect(transactions.length).to eq(1)
      expect(transactions[0].category_id).to eq(category.id)
      expect(transactions[0].subcategory_id).to eq(subcategory.id)
      expect(transactions[0].notes).to eq('Matched wrapped memo')
    end
  end
end
