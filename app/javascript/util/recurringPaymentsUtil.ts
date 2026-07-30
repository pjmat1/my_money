import moment from 'moment'

import { RecurringPaymentCandidate } from 'types/models'

export const monthKey = (date: Date) => moment(date).format('YYYY-MM')

export const previousMonthKey = (date: Date) =>
  moment(date).subtract(1, 'month').format('YYYY-MM')

export const monthLabel = (month: string) =>
  moment(month, 'YYYY-MM').format('MMM YYYY')

// Recurring payments are expenses, so candidate amounts are negative cents.
// The total is returned as a positive number.
export const totalForMonth = (
  candidates: RecurringPaymentCandidate[],
  month: string,
) =>
  Math.abs(
    candidates.reduce(
      (total, candidate) =>
        total + candidate.amount * (candidate.monthlyOccurrences[month] || 0),
      0,
    ),
  )
