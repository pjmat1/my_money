import React from 'react'

import PageHeader from 'components/common/PageHeader'
import RecurringPaymentsTable from './RecurringPaymentsTable'
import { useGetRecurringPaymentsReportQuery } from 'stores/reportApi'

import '../../stylesheets/common.scss'
import '../../stylesheets/report.scss'

const RecurringPaymentsReport = () => {
  const { data, isLoading } = useGetRecurringPaymentsReportQuery()

  return (
    <div>
      <PageHeader title="Recurring Payments Report" isLoading={isLoading} />
      <div id="report" className="container">
        <p>
          Highlights likely subscription-style charges based on the same amount
          repeated monthly over the last 6 months.
        </p>
        <RecurringPaymentsTable candidates={data || []} />
      </div>
    </div>
  )
}

export default RecurringPaymentsReport
