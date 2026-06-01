export type AccountRequest = {
  account_type: string
  name: string
  bank?: string
  starting_balance?: number
  starting_date?: string
  ticker?: string
  limit?: number
  term?: number
  interest_rate?: number
  deleted_at?: string
}

export type AccountResponse = AccountRequest & {
  id: number
  current_balance: number
}

export type BankStatementResponse = {
  id: number
  account_id: number
  file_name: string
  date: string
  transaction_count: number
}

type BankStatementTransaction = {
  account_id: number
  date: string
  amount: number
  category_id?: number
  subcategory_id?: number
  notes?: string
  memo: string
}

export type BankStatementRequest = {
  account_id: number
  file_name: string
  transactions: BankStatementTransaction[]
}

export type BudgetRequest = {
  account_id: number
  description: string
  day_of_month: number
  amount: number
  credit: boolean
}

export type BudgetResponse = BudgetRequest & {
  id: number
}

export type CategoryRequest = {
  name: string
  category_type_id: number
}

export type CategoryResponse = CategoryRequest & {
  id: number
}

export type DateRangeResponse = {
  id: number
  name: string
  custom: boolean
  default: boolean
  from_date: string
  to_date: string
}

export type SubcategoryRequest = {
  name: string
  category_id: number
}

export type SubcategoryResponse = SubcategoryRequest & {
  id: number
}

export type PatternRequest = {
  account_id: number
  match_text: string
  notes: string
  category_id: number
  subcategory_id: number
}

export type PatternResponse = PatternRequest & {
  id: number
}

export type ReconciliationRequest = {
  id: number
  account_id: number
  statement_balance: number
  statement_date: string
  reconciled: boolean
}

export type ReconciliationResponse = ReconciliationRequest

export type TransactionRequest = {
  account_id: number
  date: string
  amount: number
  category_id?: number
  subcategory_id?: number
  notes?: string
  memo?: string
  transaction_type: string
  matching_transaction_id?: number
}

export type OfxTransactionResponse = {
  account_id: number
  date: string
  memo?: string
  amount: number
  category_id?: number
  subcategory_id?: number
  notes?: string
  import: boolean
  duplicate: boolean
}

export type MatchingTransactionResponse = {
  id: number
  account_id: number
  memo: string
  notes: string
}

export type TransactionResponse = TransactionRequest & {
  id: number
  balance: number
  matching_transaction?: MatchingTransactionResponse
}

export type IncomeExpenseReportResponse = {
  income: ReportTotalsResponse
  expense: ReportTotalsResponse
}

export type ReportTotalsResponse = {
  category_totals: CategoryTotalsResponse[]
  subcategory_totals: SubcategoryTotalsResponse[]
  total: number
}

export type CategoryTotalsResponse = {
  sum: number
  category_id: number | null
}

export type SubcategoryTotalsResponse = {
  sum: number
  category_id: number
  subcategory_id: number | null
}

export type MonthTotals = [string, number]

export type TransactionReportResponse = {
  transactions: TransactionResponse[]
  month_totals: MonthTotals[]
}

export type AccountBalanceReportResponse = {
  account_id: number
  report: MonthTotals[]
}

export type RecurringPaymentCandidateResponse = {
  merchant: string
  merchant_key: string
  amount: number
  months_matched: number
  occurrence_count: number
  first_date: string
  last_date: string
  monthly_occurrences: { [month: string]: number }
  transactions: TransactionResponse[]
}

export type RecurringPaymentsReportResponse = {
  report: RecurringPaymentCandidateResponse[]
}
