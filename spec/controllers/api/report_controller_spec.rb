# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ReportController do
  describe 'EOD Balance Report' do
    it 'returns an array of eod balances' do
      account_id = 11
      from_date = '2014-01-01'
      to_date = '2014-01-2'
      data = [['01 Jan, 2014', 4.0], ['02 Jan, 2014', 14.0]]

      account = instance_double Account, id: 1
      search = instance_double Lib::BalanceSearch
      date_range = instance_double Lib::CustomDateRange

      allow(Lib::CustomDateRange).to receive(:new).with(from_date:, to_date:).and_return(date_range)
      allow(Account).to receive(:find).with(account_id).and_return(account)
      allow(Lib::BalanceSearch).to receive(:new).with(account:, date_range:).and_return(search)
      allow(search).to receive(:eod_balance).and_return(data)

      get :eod_balance, params: { account_id:, from_date:, to_date: }

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['report'].length).to eq(2)
      expect(json['report']).to eq(data)
      expect(json['account_id']).to eq(1)
    end

    it 'returns no data when account not specified' do
      get :eod_balance

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['report'].length).to eq(0)
    end
  end

  describe 'Net Balance Report' do
    it 'returns an array of eod balances across all accounts' do
      from_date = '2014-01-01'
      to_date = '2014-01-2'
      data = [['01 Jan, 2014', 4.0], ['02 Jan, 2014', 14.0]]

      search = instance_double Lib::NetBalanceSearch
      date_range = instance_double Lib::CustomDateRange

      allow(Lib::CustomDateRange).to receive(:new).with(from_date:, to_date:).and_return(date_range)
      allow(Lib::NetBalanceSearch).to receive(:new).with(date_range:).and_return(search)
      allow(search).to receive(:eod_balance).and_return(data)

      get :net_balance, params: { from_date:, to_date: }

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['report'].length).to eq(2)
      expect(json['report']).to eq(data)
    end
  end

  describe 'Income vs Expense Bar Chart' do
    it 'returns an array of monthly income and expenses' do
      income_data = [['date1', 40], ['date2', 140]]
      expense_data = [['date1', -60], ['date2', -70]]

      date_range = instance_double Lib::Last13MonthsDateRange
      income_category_type = instance_double CategoryType
      expense_category_type = instance_double CategoryType
      income_search = instance_double Lib::CategoryTypeSearch
      expense_search = instance_double Lib::CategoryTypeSearch

      allow(CategoryType).to receive_messages(
        income: income_category_type,
        expense: expense_category_type
      )

      allow(Lib::Last13MonthsDateRange).to receive(:new).and_return(date_range)
      allow(Lib::CategoryTypeSearch).to receive(:new).with(
        category_type: income_category_type, date_range:
      ).and_return(income_search)
      allow(Lib::CategoryTypeSearch).to receive(:new).with(
        category_type: expense_category_type, date_range:
      ).and_return(expense_search)

      allow(income_search).to receive(:month_totals).and_return(income_data)
      allow(expense_search).to receive(:month_totals).and_return(expense_data)

      get :income_expense_bar

      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['report'].length).to eq(2)
      expect(json['report']).to eq([['date1', 40, -60], ['date2', 140, -70]])
    end
  end

  describe 'Income vs Expense Report' do
    it 'returns report data' do
      from_date = '2014-12-01'
      to_date = '2014-12-31'
      unassigned_total = { income: 99, expense: 77 }
      total = { income: 100, expense: 101 }

      date_range = instance_double Lib::CustomDateRange
      allow(Lib::CustomDateRange).to receive(:new).with(from_date:, to_date:).and_return(date_range)

      [:income, :expense].each do |type|
        category_type = instance_double CategoryType
        category_type_search = instance_double Lib::CategoryTypeSearch
        unassigned_search = instance_double Lib::CategorySearch

        allow(CategoryType).to receive(type).and_return(category_type)
        allow(Lib::CategoryTypeSearch).to receive(:new)
          .with(date_range:, category_type:)
          .and_return(category_type_search)
        allow(Lib::CategorySearch).to receive(:new)
          .with(date_range:, category: nil, category_type:)
          .and_return(unassigned_search)
        allow(category_type_search).to receive(:group_by).with(
          :category_id, :subcategory_id
        ).and_return([{ type => 100 }])
        allow(category_type_search).to receive(:group_by).with(
          :category_id
        ).and_return([{ type => 200 }])
        allow(unassigned_search).to receive(:sum).and_return(unassigned_total[type])
        allow(category_type_search).to receive(:sum).and_return(total[type])
      end

      get :income_vs_expense, params: { from_date:, to_date: }

      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json).to eq(
        'income' => {
          'subcategory_totals' => [{ 'income' => 100 }],
          'category_totals' => [{ 'income' => 200 }] << { 'sum' => unassigned_total[:income], 'category_id' => nil },
          'total' => total[:income] + unassigned_total[:income]
        },
        'expense' => {
          'subcategory_totals' => [{ 'expense' => 100 }],
          'category_totals' => [{ 'expense' => 200 }] << { 'sum' => unassigned_total[:expense], 'category_id' => nil },
          'total' => total[:expense] + unassigned_total[:expense]
        }
      )
    end
  end

  describe 'category report' do
    it 'returns all transactions and summary data for the specified category and date range' do
      from_date = '2014-01-01'
      to_date = '2014-02-28'
      category_id = 11
      category = instance_double Category, id: category_id
      date_range = instance_double Lib::CustomDateRange
      search = instance_double Lib::CategorySearch
      t1 = FactoryBot.create(:transaction)
      t2 = FactoryBot.create(:transaction)
      month_data = [['date1', 40, -60], ['date2', 140, -70]]

      allow(Lib::CustomDateRange).to receive(:new).with(from_date:, to_date:).and_return(date_range)
      allow(Lib::CategorySearch).to receive(:new).with(category:, date_range:).and_return(search)
      allow(Category).to receive(:find).with(category_id.to_s).and_return(category)
      allow(search).to receive_messages(
        month_totals: month_data,
        transactions: [t1, t2]
      )

      get :category, params: { category_id: category.id, from_date:, to_date: }

      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['month_totals'].length).to eq(2)
      expect(json['month_totals']).to eq(month_data)
      expect(json['transactions'].length).to eq(2)
    end
  end

  describe 'subcategory report' do
    it 'returns all transactions and summary data for the specified subcategory and date range' do
      from_date = '2014-01-01'
      to_date = '2014-02-28'
      subcategory_id = 12
      subcategory = instance_double Subcategory, id: subcategory_id
      category = instance_double Category
      date_range = instance_double Lib::CustomDateRange
      search = instance_double Lib::SubcategorySearch
      t1 = FactoryBot.create(:transaction)
      t2 = FactoryBot.create(:transaction)
      month_data = [['date1', 40, -60], ['date2', 140, -70]]

      allow(Lib::CustomDateRange).to receive(:new).with(from_date:, to_date:).and_return(date_range)
      allow(Lib::SubcategorySearch).to receive(:new).with(
        category:, subcategory:, date_range:
      ).and_return(search)
      allow(Subcategory).to receive(:find).with(subcategory_id.to_s).and_return(subcategory)
      allow(subcategory).to receive(:category).and_return(category)
      allow(search).to receive_messages(
        month_totals: month_data,
        transactions: [t1, t2]
      )

      get :subcategory, params: { subcategory_id: subcategory.id, from_date:, to_date: }

      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['month_totals'].length).to eq(2)
      expect(json['month_totals']).to eq(month_data)
      expect(json['transactions'].length).to eq(2)
    end
  end

  describe 'home loan report' do
    it 'returns loan estimations for specified account' do
      account = FactoryBot.create(:account, account_type: 'loan')
      reporter = instance_double Lib::HomeLoanReporter
      allow(Lib::HomeLoanReporter).to receive(:new).with(account).and_return(reporter)
      allow(reporter).to receive(:execute).and_return(data: 'result')

      get :home_loan, params: { account_id: account.id }

      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['data']).to eq('result')
    end

    it 'returns an error if account is not a loan' do
      account = FactoryBot.create(:account, account_type: 'savings')
      expect(Lib::HomeLoanReporter).not_to receive(:new) # rubocop:disable RSpec/MessageSpies

      get :home_loan, params: { account_id: account.id }

      expect(response).to have_http_status(:bad_request)

      json = response.parsed_body
      expect(json['message']).to eq('Account is not a loan account')
    end
  end

  describe 'recurring payments report' do
    it 'returns recurring payment candidates' do
      report_data = [
        {
          merchant: 'NETFLIX.COM',
          merchant_key: 'netflix com',
          amount: -1599,
          months_matched: 4,
          occurrence_count: 4,
          first_date: '2026-01-10',
          last_date: '2026-04-10',
          monthly_occurrences: { '2026-01' => 1, '2026-02' => 1, '2026-03' => 1, '2026-04' => 1 },
          transactions: []
        }
      ]

      search = instance_double Lib::RecurringPaymentsSearch
      allow(Lib::RecurringPaymentsSearch).to receive(:new).and_return(search)
      allow(search).to receive(:report).and_return(report_data)

      get :recurring_payments

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['report']).to eq(
        [
          {
            'merchant' => 'NETFLIX.COM',
            'merchant_key' => 'netflix com',
            'amount' => -1599,
            'months_matched' => 4,
            'occurrence_count' => 4,
            'first_date' => '2026-01-10',
            'last_date' => '2026-04-10',
            'monthly_occurrences' => {
              '2026-01' => 1,
              '2026-02' => 1,
              '2026-03' => 1,
              '2026-04' => 1
            },
            'transactions' => []
          }
        ]
      )
    end
  end
end
