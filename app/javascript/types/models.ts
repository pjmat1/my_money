export enum ModelType {
  AccountLoan = 'Loan Account',
  AccountSavings = 'Savings Account',
  AccountShare = 'Share Account',
  BankStatement = 'Bank Statement',
  Budget = 'Budget',
  Category = 'Category',
  Pattern = 'Pattern',
  Subcategory = 'Subcategory',
  Transaction = 'Transaction',
}

type AccountBase = {
  accountType: string
  currentBalance: number
  name: string
  bank?: string
  openingBalance?: number
  openingBalanceDate?: string
  ticker?: string
  limit?: number
  term?: number
  interestRate?: number
  deletedAt?: string
}

export type Account = AccountBase & {
  id: number
}

export type AccountFormInput = AccountBase & {
  id?: number
}

export type AccountType = {
  id: number
  code: string
  name: string
}

export type BankStatement = {
  id: number
  accountId: number
  fileName: string
  date: string
  transactionCount: number
}

export type Budget = {
  id?: number
  accountId: number
  description: string
  dayOfMonth: number
  amount: number
  credit: boolean
}

type CategoryBase = {
  name: string
  categoryTypeId: number
}

export type Category = CategoryBase & {
  id: number
}

export type CategoryFormInput = CategoryBase & {
  id?: number
}

export type CategoryType = {
  id: number
  name: string
  code: string
  editable: boolean
}

export type DateRange = {
  id: number
  name: string
  custom: boolean
  default: boolean
  fromDate: string
  toDate: string
}

export type Pattern = {
  id?: number
  accountId: number
  matchText: string
  notes: string
  categoryId: number
  subcategoryId?: number
}

export type Reconciliation = {
  id: number
  accountId: number
  statementBalance: number
  statementDate: string
  reconciled: boolean
}

type SubcategoryBase = {
  name: string
  categoryId: number
}

export type Subcategory = SubcategoryBase & {
  id: number
}

export type SubcategoryFormInput = SubcategoryBase & {
  id?: number
}

export type OfxTransaction = {
  accountId: number
  date: string
  memo?: string
  amount: number
  categoryId?: number
  subcategoryId?: number
  notes?: string
  import: boolean
  duplicate: boolean
}

export type MatchingTransaction = {
  id: number
  accountId: number
  memo?: string
  notes?: string
}

type BaseTransaction = {
  id: number
  accountId: number
  date: string
  amount: number
  categoryId?: number
  subcategoryId?: number
  notes?: string
  matchingTransactionId?: number
  matchingTransaction?: MatchingTransaction
  memo?: string
  balance?: number
  transactionType?: string
}

export type Transaction = BaseTransaction & {
  id: number
}

export type TransactionFormInput = BaseTransaction & {
  id?: number
}

// Reports

export type PointResponse = [string, number]
export type DoublePointResponse = [string, number, number]
export type Point = [Date, number]

export type LoanReportResponse = {
  minimum_repayment?: number
  minimum_amortization: PointResponse[]
  budget_amortization: PointResponse[]
}

export type LineSeriesData = {
  name: string
  data: Point[]
  backgroundColour: string
}

export type PieChartData = {
  total: number
  data: number[]
  labels: string[]
}

export type IncomeExpencePieChart = {
  income: PieChartData
  expense: PieChartData
}

export type IncomeExpenseReport = {
  pieChartData: IncomeExpencePieChart
  tableData: IncomeExpenseTableData
}

export type IncomeExpenseTableData = {
  income: TableData
  expense: TableData
}

export type TableData = {
  total: number
  rows: TableRow[]
}

export type TableRow = {
  type: 'category' | 'subcategory'
  categoryId?: number
  subcategoryId?: number
  name: string
  amount: number
}

export type TransactionReport = {
  transactions: Transaction[]
  chartData: BarChartData
}

type BarSeriesData = {
  name: string
  data: number[]
  backgroundColour: string
  borderColor?: string
}

export type BarChartData = {
  xAxisLabels: string[]
  seriesData: BarSeriesData[]
}

export type AccountBalanceReport = {
  [accountId: string]: Point[]
}

export type RecurringPaymentCandidate = {
  merchant: string
  merchantKey: string
  amount: number
  monthsMatched: number
  occurrenceCount: number
  firstDate: string
  lastDate: string
  monthlyOccurrences: { [month: string]: number }
  transactions: Transaction[]
}
