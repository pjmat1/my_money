import React from 'react'
import store from 'stores/store'
import { act, fireEvent, render, screen, waitFor } from '@testing-library/react'
import { Provider } from 'react-redux'
import { http, HttpResponse } from 'msw'
import { setupServer } from 'msw/node'
import { expect, test, beforeAll, afterEach, afterAll } from 'vitest'

import { accountsMock, accountTypesMock } from 'mocks/accountMocks'
import PatternList from 'components/patterns/PatternList'
import {
  categoriesMock,
  categoryTypesMock,
  subcategoriesMock,
} from 'mocks/categoryMocks'
import { patternsAccount1 } from 'mocks/patternMocks'

const handlers = [
  http.get('/api/account_types', async () =>
    HttpResponse.json(accountTypesMock),
  ),
  http.get('/api/accounts', async () => HttpResponse.json(accountsMock)),
  http.get('/api/category_type2', async () =>
    HttpResponse.json(categoryTypesMock),
  ),
  http.get('/api/categories', async () => HttpResponse.json(categoriesMock)),
  http.get('/api/subcategories', async () =>
    HttpResponse.json(subcategoriesMock),
  ),
  http.get('/api/patterns', async () =>
    HttpResponse.json(patternsAccount1),
  ),
  http.put('/api/patterns/2', async () => HttpResponse.text()),
  http.delete('/api/patterns/1', async () => HttpResponse.text()),
  http.post('/api/patterns', async () => HttpResponse.text()),
]
const server = setupServer(...handlers)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

test('renders a list of patterns', async () => {
  render(
    <Provider store={store}>
      <PatternList />
    </Provider>,
  )

  // page header
  const pageTitle = screen.getByRole('heading', { level: 1 })
  expect(pageTitle.textContent).toEqual('my patterns')

  // new button
  expect(screen.getByText('New')).toBeDefined()

  await waitFor(() => {
    // pattern 1
    expect(screen.getByText('payment')).toBeDefined()
    expect(screen.getByText('work')).toBeDefined()
    expect(screen.getByText('IncomeTwo/IncomeTwoSub')).toBeDefined()

    // pattern 2
    expect(screen.getByText('Bunnings')).toBeDefined()
    expect(screen.getByText('hardware')).toBeDefined()
    expect(screen.getByText('ExpenseThree/ExpenseThreeSub')).toBeDefined()
  })

  // patterns are sorted alphabetically by match text ('Bunnings' before 'payment')
  const rows = document.querySelectorAll('#pattern-table tbody tr')
  expect(rows[0].textContent).toContain('Bunnings')
  expect(rows[1].textContent).toContain('payment')

  // click on a pattern and edit the notes
  await act(async () => {
    fireEvent(
      screen.getByText('Bunnings'),
      new MouseEvent('click', {
        bubbles: true,
        cancelable: true,
      }),
    )
  })

  let noteInput = await screen.getByLabelText('Notes')
  expect(noteInput).toBeDefined()
  let saveButton = await screen.getByText('Save')

  await act(async () => {
    fireEvent.change(noteInput, { target: { value: 'plants' } })
    fireEvent.click(saveButton)
  })

  const patternSavedMessage = await screen.getByText('Pattern saved')
  expect(patternSavedMessage).toBeDefined()

  // click on a pattern and delete it
  await act(async () => {
    fireEvent(
      screen.getByText('payment'),
      new MouseEvent('click', {
        bubbles: true,
        cancelable: true,
      }),
    )
  })

  let deleteButton = await screen.getByText('Delete')
  expect(deleteButton).toBeDefined()

  await act(async () => {
    fireEvent.click(deleteButton)
  })

  let confirmDeletedButton = await screen.getByText('Yes, Delete')
  await act(async () => {
    fireEvent.click(confirmDeletedButton)
  })

  const patternDeletedMessage = await screen.getByText('Pattern deleted')
  expect(patternDeletedMessage).toBeDefined()

  // create a new pattern
  await act(async () => {
    fireEvent(
      screen.getByText('New'),
      new MouseEvent('click', {
        bubbles: true,
        cancelable: true,
      }),
    )
  })

  const matchTextInput = await screen.getByLabelText('Match Text')
  expect(matchTextInput).toBeDefined()
  noteInput = await screen.getByLabelText('Notes')
  expect(noteInput).toBeDefined()
  saveButton = await screen.getByText('Save')

  await act(async () => {
    fireEvent.change(matchTextInput, { target: { value: 'McDonalds' } })
    fireEvent.change(noteInput, { target: { value: 'lunch' } })
    fireEvent.click(saveButton)
  })

  const validationMessage = await screen.getByText('Category is required')
  expect(validationMessage).toBeDefined()

  const categorySelect = await screen.getAllByRole('combobox')[0]
  await act(async () => {
    fireEvent.focus(categorySelect)
    fireEvent.keyDown(categorySelect, {
      key: 'ArrowDown',
      keyCode: 40,
      code: 40,
    })
  })

  const expenseOption = await screen.getByText('ExpenseThree')
  expect(expenseOption).toBeDefined()
  await act(async () => {
    fireEvent.click(expenseOption)
    fireEvent.click(saveButton)
  })

  const patternCreatedMessage = await screen.getByText('Pattern saved')
  expect(patternCreatedMessage).toBeDefined()
})

test('filters patterns by search text', async () => {
  render(
    <Provider store={store}>
      <PatternList />
    </Provider>,
  )

  await waitFor(() => {
    expect(screen.getByText('payment')).toBeDefined()
    expect(screen.getByText('Bunnings')).toBeDefined()
  })

  const searchInput = screen.getByLabelText('Search patterns')

  await act(async () => {
    fireEvent.change(searchInput, { target: { value: 'Bunnings' } })
  })

  expect(screen.getByText('Bunnings')).toBeDefined()
  expect(screen.queryByText('payment')).toBeNull()

  await act(async () => {
    fireEvent.change(searchInput, { target: { value: '' } })
  })

  expect(screen.getByText('Bunnings')).toBeDefined()
  expect(screen.getByText('payment')).toBeDefined()
})
