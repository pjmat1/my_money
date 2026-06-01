import React from 'react'
import { fireEvent, render, screen } from '@testing-library/react'
import { describe, expect, test } from 'vitest'

import RecurringPaymentsTable from 'components/reports/RecurringPaymentsTable'
import { RecurringPaymentCandidate } from 'types/models'

const candidates: RecurringPaymentCandidate[] = [
  {
    merchant: 'NETFLIX.COM',
    merchantKey: 'netflix com',
    amount: -1599,
    monthsMatched: 4,
    occurrenceCount: 4,
    firstDate: '2026-01-10',
    lastDate: '2026-04-10',
    monthlyOccurrences: {
      '2026-01': 1,
      '2026-02': 1,
      '2026-03': 1,
      '2026-04': 1,
    },
    transactions: [
      {
        id: 1,
        accountId: 2,
        date: '2026-04-10',
        memo: 'NETFLIX.COM',
        notes: '',
        amount: -1599,
      },
      {
        id: 2,
        accountId: 2,
        date: '2026-03-10',
        memo: 'NETFLIX.COM',
        notes: '',
        amount: -1599,
      },
    ],
  },
  {
    merchant: 'APPLE.COM',
    merchantKey: 'apple com',
    amount: -499,
    monthsMatched: 3,
    occurrenceCount: 3,
    firstDate: '2026-02-01',
    lastDate: '2026-04-01',
    monthlyOccurrences: {
      '2026-02': 1,
      '2026-03': 1,
      '2026-04': 1,
    },
    transactions: [
      {
        id: 3,
        accountId: 2,
        date: '2026-04-01',
        memo: 'APPLE.COM',
        notes: '',
        amount: -499,
      },
    ],
  },
]

describe('RecurringPaymentsTable', () => {
  test('renders recurring payment candidates and expands details on click', () => {
    const { container } = render(<RecurringPaymentsTable candidates={candidates} />)

    expect(screen.getByText('NETFLIX.COM')).toBeDefined()
    expect(screen.getByText('APPLE.COM')).toBeDefined()
    expect(screen.getByText('10-Apr-2026')).toBeDefined()

    expect(screen.queryByText(/acct #2/)).toBeNull()

    const netflixToggle = container.querySelector(
      '[aria-controls="recurring-transactions-netflix com--1599-2026-04-10"]',
    )
    expect(netflixToggle).toBeDefined()
    fireEvent.click(netflixToggle as Element)

    expect(screen.getAllByText(/acct #2/).length).toBe(2)
    expect(netflixToggle?.getAttribute('aria-expanded')).toBe('true')

    fireEvent.click(netflixToggle as Element)
    expect(screen.queryByText(/acct #2/)).toBeNull()
  })

  test('orders rows alphabetically by merchant', () => {
    const { container } = render(<RecurringPaymentsTable candidates={candidates} />)

    const merchantCells = Array.from(
      container.querySelectorAll('#recurring-payments tbody tr td:first-child'),
    ).map((cell) => cell.textContent)

    expect(merchantCells[0]).toBe('APPLE.COM')
    expect(merchantCells[1]).toBe('NETFLIX.COM')
  })

  test('renders an empty state when there are no candidates', () => {
    render(<RecurringPaymentsTable candidates={[]} />)

    expect(
      screen.getByText(
        'No recurring monthly payments were detected in the last 6 months.',
      ),
    ).toBeDefined()
  })
})
