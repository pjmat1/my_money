# frozen_string_literal: true

require_relative '../../models/lib/date_range'

module Api
  class ReportController < ApplicationController
    before_action :set_data_range, only: [:income_vs_expense, :eod_balance, :net_balance, :category, :subcategory]

    def index; end

    def income_vs_expense
      category_types = { income: CategoryType.income, expense: CategoryType.expense }
      report_data = { income: {}, expense: {} }

      [:income, :expense].each do |category_type|
        report_data[category_type] = get_category_type_data(category_type, category_types)
      end

      render json: report_data
    end

    def income_expense_bar
      income_type = CategoryType.income
      expense_type = CategoryType.expense

      date_range = Lib::Last13MonthsDateRange.new
      income_search = Lib::CategoryTypeSearch.new(date_range:, category_type: income_type)
      expense_search = Lib::CategoryTypeSearch.new(date_range:, category_type: expense_type)

      report_data = merge_data(income_search.month_totals, expense_search.month_totals)
      render json: { report: report_data }
    end

    # eod_balance
    # retrieves the end of day balance for the specified account for the date range
    def eod_balance
      if account.nil?
        @line_chart_data = []
      else
        search = Lib::BalanceSearch.new(account:, date_range: @date_range)
        @line_chart_data = search.eod_balance
      end

      render json: { report: @line_chart_data, account_id: account&.id }
    end

    # net_balance
    # retrieves the end of day balance for ALL accounts for the date range
    def net_balance
      search = Lib::NetBalanceSearch.new(date_range: @date_range)
      render json: { report: search.eod_balance }
    end

    def category
      set_category
      search = Lib::CategorySearch.new(category: @category, date_range: @date_range)
      transactions = search.transactions
      month_totals = search.month_totals

      report_data = { transactions:, month_totals: }
      render json: report_data
    end

    def subcategory
      set_subcategory

      if @subcategory
        @category = @subcategory.category
      else
        set_category
      end

      search = Lib::SubcategorySearch.new(category: @category, subcategory: @subcategory, date_range: @date_range)
      transactions = search.transactions
      month_totals = search.month_totals

      report_data = { transactions:, month_totals: }
      render json: report_data
    end

    def home_loan
      account = Account.find(params[:account_id])
      if account.account_type == AccountType::Loan
        render json: Lib::HomeLoanReporter.new(account).execute
      else
        render json: { message: 'Account is not a loan account' }, status: :bad_request
      end
    end

    def recurring_payments
      search = Lib::RecurringPaymentsSearch.new
      render json: { report: search.report }
    end

    private

    def merge_data(income_data, expense_data)
      data = []
      income_data.each_with_index do |a, i|
        data << [a[0], a[1], expense_data[i][1]]
      end
      data
    end

    def get_category_type_data(category_type, category_types)
      data = {}
      search = create_category_type_search(category_type, category_types)
      data[:subcategory_totals] = search.group_by(:category_id, :subcategory_id)
      data[:category_totals] = search.group_by(:category_id)
      unassigned_search = create_unassigned_search(category_type, category_types)
      unassigned_sum = unassigned_search.sum
      data[:category_totals] << { sum: unassigned_sum, category_id: nil } if unassigned_sum != 0
      data[:total] = search.sum + unassigned_sum
      data
    end

    def create_category_type_search(category_type, category_types)
      Lib::CategoryTypeSearch.new(date_range: @date_range, category_type: category_types[category_type])
    end

    def create_unassigned_search(category_type, category_types)
      Lib::CategorySearch.new(date_range: @date_range, category: nil, category_type: category_types[category_type])
    end

    def set_data_range
      @date_range = Lib::CustomDateRange.new from_date: params[:from_date], to_date: params[:to_date]
    end

    def set_category
      @category = params.key?(:category_id) && params[:category_id].present? ? Category.find(params[:category_id]) : nil
    end

    def set_subcategory
      @subcategory = subcategory_in_params? ? Subcategory.find(params[:subcategory_id]) : nil
    end

    def subcategory_in_params?
      params.key?(:subcategory_id) && params[:subcategory_id].present?
    end
  end
end
