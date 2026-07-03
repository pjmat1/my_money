require 'rails_helper'

feature 'Patterns', type: :feature do
  after :all  do
    DatabaseCleaner.clean
  end

  scenario 'User creates, edits and deletes global patterns', js: true  do
    visit_categories
    create_categories

    visit_accounts
    create_savings_account
    create_loan_account

    pattern_spec
  end
end
