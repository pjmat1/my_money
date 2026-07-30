import {
  monthKey,
  monthLabel,
  previousMonthKey,
  totalForMonth,
} from 'util/recurringPaymentsUtil'
import { RecurringPaymentCandidate } from 'types/models'

const candidate = (
  amount: number,
  monthlyOccurrences: { [month: string]: number },
): RecurringPaymentCandidate => ({
  merchant: 'MERCHANT',
  merchantKey: 'merchant',
  amount,
  monthsMatched: Object.keys(monthlyOccurrences).length,
  occurrenceCount: Object.values(monthlyOccurrences).reduce(
    (total, count) => total + count,
    0,
  ),
  firstDate: '2026-02-01',
  lastDate: '2026-04-01',
  monthlyOccurrences,
  transactions: [],
})

describe('recurringPaymentsUtil', () => {
  describe('monthKey', () => {
    it('formats a date as YYYY-MM', () => {
      expect(monthKey(new Date('2026-04-15'))).toEqual('2026-04')
    })
  })

  describe('previousMonthKey', () => {
    it('formats the month before a date as YYYY-MM', () => {
      expect(previousMonthKey(new Date('2026-04-15'))).toEqual('2026-03')
    })

    it('rolls back over a year boundary', () => {
      expect(previousMonthKey(new Date('2026-01-15'))).toEqual('2025-12')
    })
  })

  describe('monthLabel', () => {
    it('formats a month key for display', () => {
      expect(monthLabel('2026-04')).toEqual('Apr 2026')
    })
  })

  describe('totalForMonth', () => {
    it('sums the amounts charged in the month as a positive number', () => {
      const candidates = [
        candidate(-1599, { '2026-03': 1, '2026-04': 1 }),
        candidate(-499, { '2026-03': 1, '2026-04': 1 }),
      ]

      expect(totalForMonth(candidates, '2026-04')).toEqual(2098)
    })

    it('counts a merchant charged more than once in the month', () => {
      const candidates = [
        candidate(-1599, { '2026-04': 2 }),
        candidate(-499, { '2026-04': 1 }),
      ]

      expect(totalForMonth(candidates, '2026-04')).toEqual(3697)
    })

    it('ignores candidates with no charge in the month', () => {
      const candidates = [
        candidate(-1599, { '2026-03': 1 }),
        candidate(-499, { '2026-04': 1 }),
      ]

      expect(totalForMonth(candidates, '2026-04')).toEqual(499)
    })

    it('returns zero when there are no candidates', () => {
      expect(totalForMonth([], '2026-04')).toEqual(0)
    })
  })
})
