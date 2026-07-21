import React from 'react'
import { render, screen } from '@testing-library/react'
import { describe, it, expect } from 'vitest'
import D3PieChart from 'components/reports/D3PieChart'

describe('D3PieChart', () => {
  it('renders a chart container', () => {
    render(<D3PieChart data={[500, 200]} labels={['One', 'Two']} />)

    expect(screen.getByRole('img')).toBeInTheDocument()
    expect(screen.getByRole('img')).toHaveAttribute('width', '450px')
    expect(screen.getByRole('img')).toHaveAttribute('height', '450px')
  })
})
