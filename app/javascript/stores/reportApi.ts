import {
  Account,
  AccountBalanceReport,
  BarChartData,
  DateRange,
  DoublePointResponse,
  LineSeriesData,
  LoanReportResponse,
  PointResponse,
  RecurringPaymentCandidate,
  TransactionReport,
} from 'types/models'
import {
  TransactionReportResponse,
  IncomeExpenseReportResponse,
  AccountBalanceReportResponse,
  RecurringPaymentsReportResponse,
} from 'types/api'
import {
  chartDataForCombo,
  transformAccountBalances,
  transformLoanReport,
  transformMonthTotals,
} from 'transformers/reportTransformer'
import { applicationApi } from './applicationApi'
import { transformFromApi } from 'transformers/transactionTransformer'

type CategoryReportParams = {
  categoryId?: number
  dateRange?: DateRange
}

type SubcategoryReportParams = {
  categoryId?: number
  subcategoryId?: number
  dateRange?: DateRange
}

type AccountBalanceReportParams = {
  accounts: Account[]
  dateRange?: DateRange
}

export const reportApi = applicationApi.injectEndpoints({
  endpoints: (builder) => ({
    getLoanReport: builder.query<LineSeriesData[], number>({
      query(accountId) {
        return {
          url: `report/home_loan?account_id=${accountId}`,
        }
      },
      transformResponse: (loanReport: LoanReportResponse) =>
        transformLoanReport(loanReport),
      providesTags: () => ['loan-report'],
    }),
    getIncomeVsExpensesReport: builder.query<
      IncomeExpenseReportResponse,
      DateRange | undefined
    >({
      query(dateRange) {
        return {
          url: `report/income_vs_expense?from_date=${dateRange?.fromDate}&to_date=${dateRange?.toDate}`,
        }
      },
      providesTags: () => ['income-expense-report'],
    }),
    getIncomeExpensesBarReport: builder.query<BarChartData | null, void>({
      query() {
        return {
          url: 'report/income_expense_bar',
        }
      },
      transformResponse: (response: { report: DoublePointResponse[] }) =>
        chartDataForCombo(response.report),
      providesTags: () => ['income-expense-bar-report'],
    }),
    getCategoryReport: builder.query<TransactionReport, CategoryReportParams>({
      query({ categoryId, dateRange }) {
        return {
          url: `report/category?category_id=${categoryId || ''}&from_date=${dateRange?.fromDate}&to_date=${dateRange?.toDate}`,
        }
      },
      transformResponse: (report: TransactionReportResponse) => ({
        transactions: report.transactions.map((transaction) =>
          transformFromApi(transaction),
        ),
        chartData: transformMonthTotals(report.month_totals),
      }),
      providesTags: () => ['category-report'],
    }),
    getSubcategoryReport: builder.query<
      TransactionReport,
      SubcategoryReportParams
    >({
      query({ categoryId, subcategoryId, dateRange }) {
        return {
          url: `report/subcategory?category_id=${categoryId || ''}&subcategory_id=${subcategoryId || ''}&from_date=${dateRange?.fromDate}&to_date=${dateRange?.toDate}`,
        }
      },
      transformResponse: (report: TransactionReportResponse) => ({
        transactions: report.transactions.map((transaction) =>
          transformFromApi(transaction),
        ),
        chartData: transformMonthTotals(report.month_totals),
      }),
      providesTags: () => ['subcategory-report'],
    }),
    getAccountBalanceReport: builder.query<
      AccountBalanceReport | undefined,
      AccountBalanceReportParams
    >({
      queryFn: async (arg, api, extraOptions, baseQuery) => {
        const requests = arg.accounts.map((account) =>
          baseQuery({
            url: `report/eod_balance?account_id=${account.id}&from_date=${arg.dateRange?.fromDate}&to_date=${arg.dateRange?.toDate}`,
          }),
        )

        const results = await Promise.all(requests)
        const data = transformAccountBalances(
          results.map((r) => r.data as AccountBalanceReportResponse),
        )

        return { data }
      },
    }),
    getNetBalanceReport: builder.query<PointResponse[], DateRange | undefined>({
      query(dateRange) {
        return {
          url: `report/net_balance?from_date=${dateRange?.fromDate}&to_date=${dateRange?.toDate}`,
        }
      },
      transformResponse: (response: { report: PointResponse[] }) =>
        response.report,
      providesTags: () => ['net-balance-report'],
    }),
    getRecurringPaymentsReport: builder.query<RecurringPaymentCandidate[], void>({
      query() {
        return {
          url: 'report/recurring_payments',
        }
      },
      transformResponse: (response: RecurringPaymentsReportResponse) =>
        response.report.map((candidate) => ({
          merchant: candidate.merchant,
          merchantKey: candidate.merchant_key,
          amount: candidate.amount,
          monthsMatched: candidate.months_matched,
          occurrenceCount: candidate.occurrence_count,
          firstDate: candidate.first_date,
          lastDate: candidate.last_date,
          monthlyOccurrences: candidate.monthly_occurrences,
          transactions: candidate.transactions.map((transaction) =>
            transformFromApi(transaction),
          ),
        })),
      providesTags: () => ['recurring-payments-report'],
    }),
  }),
})

export const {
  useGetLoanReportQuery,
  useGetIncomeVsExpensesReportQuery,
  useGetIncomeExpensesBarReportQuery,
  useGetCategoryReportQuery,
  useGetSubcategoryReportQuery,
  useGetAccountBalanceReportQuery,
  useGetNetBalanceReportQuery,
  useGetRecurringPaymentsReportQuery,
} = reportApi
