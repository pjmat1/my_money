# frozen_string_literal: true

require 'rails_helper'

describe 'CsvParser' do
  it 'returns the transactions from the CSV file' do
    file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test.csv'))

    parser = Lib::CsvParser.new file
    transactions = parser.transactions

    expect(transactions.length).to eq(2)

    expect(transactions[0].memo).to eq('Some Income')
    expect(transactions[0].date).to eq(Date.parse('2016-04-11'))
    expect(transactions[0].amount).to eq(1001)

    expect(transactions[1].memo).to eq('An Expense')
    expect(transactions[1].date).to eq(Date.parse('2016-04-11'))
    expect(transactions[1].amount).to eq(-2341)
  end

  it 'returns the transactions from the CUA formatted CSV file' do
    file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test_cua.csv'))

    parser = Lib::CsvParser.new file
    transactions = parser.transactions

    expect(transactions.length).to eq(2)

    expect(transactions[0].memo).to eq('Purchase')
    expect(transactions[0].date).to eq(Date.parse('2016-10-29'))
    expect(transactions[0].amount).to eq(-111_111)
    expect(transactions[1].memo).to eq('Money In')
    expect(transactions[1].date).to eq(Date.parse('2016-10-28'))
    expect(transactions[1].amount).to eq(302_099)
  end

  it 'returns the transactions from the People First formatted CSV file' do
    file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test_people_first.csv'))

    parser = Lib::CsvParser.new file
    transactions = parser.transactions

    expect(transactions.length).to eq(2)

    expect(transactions[0].memo).to eq('Coffee Shop')
    expect(transactions[0].date).to eq(Date.parse('2026-06-11'))
    expect(transactions[0].amount).to eq(-1600)
    expect(transactions[1].memo).to eq('Direct Credit')
    expect(transactions[1].date).to eq(Date.parse('2026-06-10'))
    expect(transactions[1].amount).to eq(382_000)
  end

  it 'falls back to merchant name then transaction type for People First memo' do
    csv = <<~CSV
      Date,Amount,Account Number,,Transaction Type,Transaction Details,Balance,Category,Merchant Name,Processed On
      11/06/2026,-16.00,123456,,Card Payment,,-100.00,Food,Coffee Club,11/06/2026
      10/06/2026,3820.00,123456,,Direct Credit,,3720.00,Income,,10/06/2026
    CSV

    file = StringIO.new(csv)

    parser = Lib::CsvParser.new file
    transactions = parser.transactions

    expect(transactions.length).to eq(2)
    expect(transactions[0].memo).to eq('Coffee Club')
    expect(transactions[1].memo).to eq('Direct Credit')
  end

  it 'does not import pending purchase authorisations from CSV' do
    csv = <<~CSV
      Date,Amount,Account Number,,Transaction Type,Transaction Details,Balance,Category,Merchant Name,Processed On
      12/06/2026,-10.00,123456,,Card Payment,PURCHASE AUTHORISATION,-10.00,Food,Grocer,12/06/2026
      11/06/2026,-16.00,123456,,Card Payment,Coffee Shop,-26.00,Food,Coffee Shop,11/06/2026
    CSV

    file = StringIO.new(csv)

    parser = Lib::CsvParser.new file
    transactions = parser.transactions

    expect(transactions.length).to eq(1)
    expect(transactions[0].memo).to eq('Coffee Shop')
    expect(transactions[0].date).to eq(Date.parse('2026-06-11'))
    expect(transactions[0].amount).to eq(-1600)
  end
end
