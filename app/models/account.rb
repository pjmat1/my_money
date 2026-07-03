# frozen_string_literal: true

#
#  Account
#
#  id: int, primary key
#  account_type: string, enum
#  name: string
#  bank: string
#  starting_balance: decimal
#  starting_date: date
#
class Account < ApplicationRecord
  include ClassyEnum::ActiveRecord
  classy_enum_attr :account_type

  # model relationships
  # belongs_to :account_type
  has_many :transactions, dependent: nil
  has_many :reconciliations, dependent: :destroy
  has_many :bank_statements, dependent: :destroy
  has_many :budgets, dependent: :destroy

  # validations
  validates :account_type, presence: true
  validates :name, presence: true
  validates :starting_balance, presence: true, numericality: true, if: :savings?
  validates :starting_date, presence: true, if: :savings_or_loan?
  validates :ticker, presence: true, if: :share?
  validates :limit, presence: true, numericality: true, if: :loan?
  validates :term, presence: true, numericality: true, if: :loan?
  validates :interest_rate, presence: true, numericality: true, if: :loan?

  def savings?
    account_type == AccountType::Savings
  end

  def share?
    account_type == AccountType::Share
  end

  def loan?
    account_type == AccountType::Loan
  end

  def savings_or_loan?
    savings? || loan?
  end

  # defaults
  after_initialize :init

  def init
    self.starting_balance ||= 0.0
  end

  # current_balance gets the balance of the last transaction, or if none
  # exist, then the starting balance of the account
  def current_balance
    # if there are no transactions, return starting balance of account
    return starting_balance if transactions.empty?

    # otherwise return balance of last transaction
    transactions.order(date: :asc, id: :asc).last.balance
  end

  # eod_balance gets the end of day balance for this account for the given date
  def eod_balance(date)
    last_transaction = transactions.where('date <= ?', date).date_order.last
    last_transaction.nil? ? starting_balance : last_transaction.balance
  end
end
