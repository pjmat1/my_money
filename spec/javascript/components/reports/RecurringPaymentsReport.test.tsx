import React from 'react'
import { render, screen } from '@testing-library/react'
import { Provider } from 'react-redux'
import { beforeEach, describe, expect, test, vi } from 'vitest'

import store from 'stores/store'
import RecurringPaymentsReport from 'components/reports/RecurringPaymentsReport'
import { useGetRecurringPaymentsReportQuery } from 'stores/reportApi'

vi.mock('stores/reportApi', () => ({
  useGetRecurringPaymentsReportQuery: vi.fn(),
}))

const useRecurringPaymentsQuery = vi.mocked(useGetRecurringPaymentsReportQuery)

describe('RecurringPaymentsReport', () => {
  beforeEach(() => {
    useRecurringPaymentsQuery.mockReturnValue({
      data: [
        {
          merchant: 'Spotify',
          merchantKey: 'spotify',
          amount: -1299,
          monthsMatched: 3,
          occurrenceCount: 3,
          firstDate: '2026-02-02',
          lastDate: '2026-04-02',
          monthlyOccurrences: {
            '2026-02': 1,
            '2026-03': 1,
            '2026-04': 1,
          },
          transactions: [
            {
              id: 1,
              accountId: 1,
              date: '2026-04-02',
              memo: 'Spotify',
              notes: '',
              amount: -1299,
            },
          ],
        },
      ],
      isLoading: false,
    } as any)
  })

  test('renders recurring payment rows from API data', async () => {
    render(
      <Provider store={store}>
        <RecurringPaymentsReport />
      </Provider>,
    )

    expect(screen.getByRole('heading', { level: 1 }).textContent).toEqual(
      'Recurring Payments Report',
    )

    expect(screen.getByText('Spotify')).toBeDefined()
    expect(screen.getByText('02-Apr-2026')).toBeDefined()
  })

  test('renders empty state when no recurring payments are returned', async () => {
    useRecurringPaymentsQuery.mockReturnValue({
      data: [],
      isLoading: false,
    } as any)

    render(
      <Provider store={store}>
        <RecurringPaymentsReport />
      </Provider>,
    )

    expect(
      screen.getByText(
        'No recurring monthly payments were detected in the last 6 months.',
      ),
    ).toBeDefined()
  })
})
