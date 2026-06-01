# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lib::RecurringPaymentsSearch do
  describe '#report' do
    it 'returns expenses that repeat in at least 3 distinct months with same normalized merchant and amount' do
      account = FactoryBot.create(:account, account_type: 'savings')
      date_range = Lib::CustomDateRange.new(from_date: '2026-01-01', to_date: '2026-06-30')

      FactoryBot.create(:transaction, account:, date: '2026-01-04', memo: 'NETFLIX.COM', amount: -1599)
      FactoryBot.create(:transaction, account:, date: '2026-02-05', memo: 'Netflix com', amount: -1599)
      FactoryBot.create(:transaction, account:, date: '2026-03-06', memo: 'Netflix-com', amount: -1599)

      FactoryBot.create(:transaction, account:, date: '2026-04-07', memo: 'NETFLIX.COM', amount: -1799)
      FactoryBot.create(:transaction, account:, date: '2026-02-07', memo: 'ONE OFF', amount: -455)
      FactoryBot.create(:transaction, account:, date: '2026-01-10', memo: 'SALARY', amount: 100_000)

      result = described_class.new(date_range:).report

      expect(result.length).to eq(1)

      candidate = result[0]
      expect(['NETFLIX.COM', 'Netflix com', 'Netflix-com']).to include(candidate[:merchant])
      expect(candidate[:merchant_key]).to eq('netflix com')
      expect(candidate[:amount]).to eq(-1599)
      expect(candidate[:months_matched]).to eq(3)
      expect(candidate[:occurrence_count]).to eq(3)
      expect(candidate[:first_date]).to eq('2026-01-04')
      expect(candidate[:last_date]).to eq('2026-03-06')
      expect(candidate[:monthly_occurrences]).to eq(
        {
          '2026-01' => 1,
          '2026-02' => 1,
          '2026-03' => 1
        }
      )
      expect(candidate[:transactions].map(&:id).length).to eq(3)
    end

    it 'counts a month once for threshold even if there are multiple transactions in that month' do
      account = FactoryBot.create(:account, account_type: 'savings')
      date_range = Lib::CustomDateRange.new(from_date: '2026-01-01', to_date: '2026-06-30')

      FactoryBot.create(:transaction, account:, date: '2026-01-04', memo: 'Spotify', amount: -1299)
      FactoryBot.create(:transaction, account:, date: '2026-01-15', memo: 'Spotify', amount: -1299)
      FactoryBot.create(:transaction, account:, date: '2026-02-05', memo: 'Spotify', amount: -1299)
      FactoryBot.create(:transaction, account:, date: '2026-03-05', memo: 'Spotify', amount: -1299)

      result = described_class.new(date_range:).report

      expect(result.length).to eq(1)
      candidate = result[0]
      expect(candidate[:months_matched]).to eq(3)
      expect(candidate[:occurrence_count]).to eq(4)
      expect(candidate[:monthly_occurrences]).to eq(
        {
          '2026-01' => 2,
          '2026-02' => 1,
          '2026-03' => 1
        }
      )
    end
  end
end
