import React from 'react'
import { render, screen } from '@testing-library/react'
import { describe, it, expect } from 'vitest'
import ChartLegend from 'components/reports/ChartLegend'

describe('ChartLegend', () => {
  it('renders a legend item for each series', () => {
    const seriesData = [
      { name: 'Series One', backgroundColour: 'red', data: [] },
      { name: 'Series Two', backgroundColour: 'blue', data: [] },
    ]

    render(<ChartLegend seriesData={seriesData} />)

    expect(screen.getByText('Series One')).toBeInTheDocument()
    expect(screen.getByText('Series Two')).toBeInTheDocument()
  })
})
