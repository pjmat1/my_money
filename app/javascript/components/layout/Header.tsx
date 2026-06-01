import React from 'react'
import { Link } from 'react-router-dom'
import { LinkContainer } from 'react-router-bootstrap'
import { Navbar, Nav, NavDropdown } from 'react-bootstrap'

import '../../stylesheets/nav.scss'

const Header = () => (
  <Navbar>
    <Navbar.Brand>
      <Link to="/">
        <strong>my</strong> money
      </Link>
    </Navbar.Brand>
    <Nav>
      <LinkContainer to="/accounts">
        <Nav.Link>accounts</Nav.Link>
      </LinkContainer>
      <LinkContainer to="/transactions">
        <Nav.Link>transactions</Nav.Link>
      </LinkContainer>
      <LinkContainer to="/categories">
        <Nav.Link>categories</Nav.Link>
      </LinkContainer>
      <LinkContainer to="/patterns">
        <Nav.Link>patterns</Nav.Link>
      </LinkContainer>
      <NavDropdown title="reports" id="basic-nav-dropdown">
        <LinkContainer to="/reports/incomeVsExpenses">
          <NavDropdown.Item>Income vs Expenses</NavDropdown.Item>
        </LinkContainer>
        <LinkContainer to="/reports/incomeVsExpenseBar">
          <NavDropdown.Item>Income/Expense Bar Chart</NavDropdown.Item>
        </LinkContainer>
        <LinkContainer to="/reports/categoryReport">
          <NavDropdown.Item>Category Report</NavDropdown.Item>
        </LinkContainer>
        <LinkContainer to="/reports/subcategoryReport">
          <NavDropdown.Item>Subcategory Report</NavDropdown.Item>
        </LinkContainer>
        <LinkContainer to="/reports/recurringPayments">
          <NavDropdown.Item>Recurring Payments</NavDropdown.Item>
        </LinkContainer>
        <NavDropdown.Divider />
        <LinkContainer to="/reports/accountBalance">
          <NavDropdown.Item>Account Balance Line Chart</NavDropdown.Item>
        </LinkContainer>
        <LinkContainer to="/reports/netBalance">
          <NavDropdown.Item>Net Balance Chart</NavDropdown.Item>
        </LinkContainer>        
      </NavDropdown>
    </Nav>
  </Navbar>
)

export default Header
