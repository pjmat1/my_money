import React, { Fragment, useState } from 'react'
import moment from 'moment'

import Amount from 'components/common/Amount'
import { RecurringPaymentCandidate } from 'types/models'

type RecurringPaymentsTableProps = {
  candidates: RecurringPaymentCandidate[]
}

const recurringDescription = (merchant: string) => {
  if (merchant.length > 0) return merchant
  return 'Unlabelled merchant'
}

const transactionDescription = (
  memo: string | undefined,
  notes: string | undefined,
) => {
  const description = memo || notes || 'No description'
  return description.length > 0 ? description : 'No description'
}

const RecurringPaymentsTable = ({
  candidates,
}: RecurringPaymentsTableProps) => {
  const [expandedRows, setExpandedRows] = useState<{ [rowKey: string]: boolean }>(
    {},
  )

  const toggleRow = (rowKey: string) => {
    setExpandedRows((existingRows) => ({
      ...existingRows,
      [rowKey]: !existingRows[rowKey],
    }))
  }

  if (candidates.length === 0) {
    return (
      <div className="empty-state">
        No recurring monthly payments were detected in the last 6 months.
      </div>
    )
  }

  const sortedCandidates = [...candidates].sort((a, b) => {
    const merchantA = recurringDescription(a.merchant).toLowerCase()
    const merchantB = recurringDescription(b.merchant).toLowerCase()
    return merchantA.localeCompare(merchantB)
  })

  return (
    <table className="table table-hover table-report" id="recurring-payments">
      <thead>
        <tr>
          <th>Merchant</th>
          <th className="currency">Amount</th>
          <th>Months matched</th>
          <th>Charges</th>
          <th>Last charge</th>
          <th>Details</th>
        </tr>
      </thead>
      <tbody>
        {sortedCandidates.map((candidate) => {
          const rowKey = `${candidate.merchantKey}-${candidate.amount}-${candidate.lastDate}`
          const isExpanded = expandedRows[rowKey] == true

          return (
            <Fragment key={rowKey}>
              <tr>
                <td>{recurringDescription(candidate.merchant)}</td>
                <td className="currency">
                  <Amount amount={candidate.amount} />
                </td>
                <td>{candidate.monthsMatched}</td>
                <td>{candidate.occurrenceCount}</td>
                <td>{moment(candidate.lastDate, 'YYYY-MM-DD').format('DD-MMM-YYYY')}</td>
                <td>
                  <span
                    className="click-me"
                    role="button"
                    tabIndex={0}
                    onClick={() => toggleRow(rowKey)}
                    onKeyDown={(event) => {
                      if (event.key === 'Enter' || event.key === ' ') {
                        event.preventDefault()
                        toggleRow(rowKey)
                      }
                    }}
                    aria-expanded={isExpanded}
                    aria-controls={`recurring-transactions-${rowKey}`}
                  >
                    <i
                      className={`fa-solid ${isExpanded ? 'fa-chevron-up' : 'fa-chevron-down'} pr-1`}
                    ></i>
                    {isExpanded ? 'Hide details' : 'Show details'}
                  </span>
                </td>
              </tr>
              {isExpanded ? (
                <tr id={`recurring-transactions-${rowKey}`}>
                  <td colSpan={6}>
                    <ul>
                      {candidate.transactions.map((transaction) => (
                        <li key={transaction.id}>
                          {moment(transaction.date, 'YYYY-MM-DD').format('DD-MMM-YYYY')} |{' '}
                          {transactionDescription(transaction.memo, transaction.notes)}
                          {' | '}acct #{transaction.accountId}
                        </li>
                      ))}
                    </ul>
                  </td>
                </tr>
              ) : null}
            </Fragment>
          )
        })}
      </tbody>
    </table>
  )
}

export default RecurringPaymentsTable
