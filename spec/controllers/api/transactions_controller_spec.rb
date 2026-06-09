# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::TransactionsController do
  describe 'POST import' do
    it 'renders an empty imported transaction collection without error' do
      account = instance_double(Account)
      importer = instance_double(Lib::TransactionImporter)

      allow(controller).to receive(:account).and_return(account)
      allow(Lib::TransactionImporter).to receive(:new).with(account, 'uploaded-file').and_return(importer)
      allow(importer).to receive(:execute).and_return([])

      post :import, params: { account_id: 1, data_file: 'uploaded-file' }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq({ 'imported_transactions' => [] })
    end
  end

  describe 'GET index' do
    it 'returns all transactions for specified account for specified date' do
      t1 = FactoryBot.create(:transaction, date: '2014-07-03')
      t2 = FactoryBot.create(:transaction, account: t1.account, date: '2014-07-09')
      FactoryBot.create(:transaction, account: t1.account, date: '2014-07-21')
      FactoryBot.create(:transaction, account: t1.account, date: '2014-06-30')

      get :index, params: { account_id: t1.account.id, from_date: '2014-07-01', to_date: '2014-07-10' }

      expect(response).to have_http_status(:ok)
      t1.reload
      t2.reload

      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:transactions].length).to eq(2)
      expect(json[:transactions][0][:id]).to eq(t2.id)
      expect(json[:transactions][1][:id]).to eq(t1.id)
    end

    it 'returns all transactions for specified account for specified date and description' do
      t1 = FactoryBot.create(:transaction, date: '2014-01-01')
      t2 = FactoryBot.create(:transaction, account: t1.account, date: '2014-01-01', memo: 'melanie')
      FactoryBot.create(:transaction, account: t1.account, date: '2014-01-01', notes: 'something')
      t4 = FactoryBot.create(:transaction, account: t1.account, date: '2014-01-01', notes: 'for Mel')
      t5 = FactoryBot.create(:transaction, account: t1.account, date: '2014-01-01', memo: 'melanie', notes: 'melanie')

      get :index, params: {
        account_id: t1.account.id,
        from_date: '2014-01-01',
        to_date: '2014-01-01',
        description: 'mel'
      }

      expect(response).to have_http_status(:ok)
      t1.reload
      t2.reload

      json = response.parsed_body
      expect(json['transactions'].length).to eq(3)
      expect(json['transactions'][0]['id']).to eq(t5.id)
      expect(json['transactions'][1]['id']).to eq(t4.id)
      expect(json['transactions'][2]['id']).to eq(t2.id)
    end
  end

  describe 'POST create one transaction' do
    context 'with valid params' do
      it 'creates a new Transaction' do
        account = FactoryBot.create(:account)

        expect do
          post :create, params: {
            account_id: account.id,
            transaction: FactoryBot.attributes_for(:transaction, account_id: account.id)
          }
        end.to change(Transaction, :count).by(1)
      end

      it 'sends the transaction, with status success' do
        a = FactoryBot.create(:account)
        matched_txn = FactoryBot.create(:transaction, date: '1-Jan-2015', amount: -1000)
        post :create, params: { account_id: a.id, transaction: {
          account_id: a.id,
          transaction_type: 'bank_transaction',
          date: '1-Jan-2015',
          notes: 'This is a note',
          memo: 'This is a memo',
          unit_price: 50,
          quantity: 20,
          amount: 1000,
          matching_transaction_id: matched_txn.id
        } }
        expect(response).to have_http_status(:created)

        transaction = Transaction.second
        expect(transaction.transaction_type).to be_a(TransactionType::BankTransaction)
        expect(transaction.unit_price).to eq(50)
        expect(transaction.quantity).to eq(20)
        expect(transaction.amount).to eq(1000)
        expect(transaction.notes).to eq('This is a note')
        expect(transaction.memo).to eq('This is a memo')
        expect(transaction.date).to eq(Date.parse('1-Jan-2015'))
        expect(transaction.matching_transaction).to eq(matched_txn)

        response_txn = JSON.parse(response.body, symbolize_names: true)[:transaction]
        expect(response_txn).to include(
          id: transaction.id,
          transaction_type: 'bank_transaction',
          unit_price: 50,
          quantity: 20,
          amount: 1000,
          notes: 'This is a note',
          memo: 'This is a memo',
          date: '2015-01-01',
          matching_transaction: {
            id: matched_txn.id,
            account_id: matched_txn.account_id,
            notes: matched_txn.notes,
            memo: matched_txn.memo
          }
        )
      end
    end

    context 'with invalid params' do
      it 'does not create a new transaction' do
        account = FactoryBot.create(:account)
        expect do
          post :create, params: { account_id: account.id, transaction: {
            account_id: account.id,
            transaction_type: 'bank_transaction',
            date: '1-Jan-2015'
          } }
        end.not_to change(Transaction, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST create multiple transactions' do
    context 'with valid params' do
      it 'creates new Transactions' do
        account = FactoryBot.create(:account)
        expect do
          post :create, params: {
            account_id: account.id,
            _json: [
              FactoryBot.attributes_for(:transaction, account_id: account.id),
              FactoryBot.attributes_for(:transaction, account_id: account.id)
            ]
          }
        end.to change(Transaction, :count).by(2)
      end
    end
  end

  describe 'PUT update' do
    context 'with valid params' do
      it 'updates the requested transaction' do
        new_subcategory = FactoryBot.create(:subcategory)
        transaction = FactoryBot.create(:transaction)

        new_attrs = {
          date: '2014-08-19',
          amount: 1011,
          memo: 'New memo',
          notes: 'New note',
          subcategory_id: new_subcategory.id,
          category_id: new_subcategory.category.id
        }

        put :update, params: { id: transaction.id, account_id: transaction.account_id, transaction: new_attrs }

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['transaction'].symbolize_keys).to include(new_attrs)
      end
    end

    context 'with invalid params' do
      it 'assigns the transaction as @transaction' do
        transaction = FactoryBot.create(:transaction)
        put :update, params: {
          id: transaction.id,
          account_id: transaction.account_id,
          transaction: FactoryBot.attributes_for(:transaction_invalid, account_id: transaction.account_id)
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested transaction' do
      transaction = FactoryBot.create(:transaction)
      expect do
        delete :destroy, params: { id: transaction.id, account_id: transaction.account_id }
      end.to change(Transaction, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'doesnt destroy the transaction if it has been reconciled' do
      account = FactoryBot.create(:account)
      reconciliation = FactoryBot.create(:reconciliation, account:)
      transaction = FactoryBot.create(:transaction, account:, reconciliation:)

      expect do
        delete :destroy, params: { id: transaction.id, account_id: transaction.account_id }
      end.not_to change(Transaction, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      json = response.parsed_body
      expect(json['message']).to eq('Cannot delete a transaction which has been reconciled')
    end
  end

  describe 'unreconciled' do
    it 'returns all unreconciled transactions' do
      account = FactoryBot.create(:account)
      reconciliation = FactoryBot.create(:reconciliation, account:)

      FactoryBot.create(:transaction, account: reconciliation.account, reconciliation: nil)
      FactoryBot.create(:transaction, account: reconciliation.account, reconciliation: nil)
      FactoryBot.create(:transaction, account: reconciliation.account, reconciliation:)

      get :unreconciled, params: { account_id: account.id }

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['transactions'].length).to eq(2)
    end
  end

  describe 'import' do
    it 'calls the transaction importer' do
      account = FactoryBot.create(:account)
      file = 'data_file'
      importer = instance_double(Lib::TransactionImporter)
      transaction = ImportedTransaction.new(date: '2014-07-01', amount: 100, memo: 'transaction')

      allow(Lib::TransactionImporter).to receive(:new).with(account, file).and_return(importer)
      allow(importer).to receive(:execute).and_return([transaction])

      post :import, params: { account_id: account.id, data_file: file }

      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['imported_transactions'].length).to eq(1)
      expect(json['imported_transactions'][0]['memo']).to eq('transaction')
    end
  end

  describe 'matching' do
    it 'returns transactions from other accounts which match given params, and are unmatched' do
      account1 = FactoryBot.create(:account)
      account2 = FactoryBot.create(:account)

      date = '2014-07-01'
      amount = 333

      t0 = FactoryBot.create(:transaction, account: account1, date:, amount:)
      t1 = FactoryBot.create(:transaction, account: account2, date:, amount: -amount)
      t2 = FactoryBot.create(:transaction, account: account2, date:, amount: -amount)
      FactoryBot.create(:transaction, account: account1, date:, amount:, matching_transaction_id: t2.id)
      FactoryBot.create(:transaction, account: account2, date:, amount:)
      FactoryBot.create(:transaction, account: account1, date:, amount: -amount)
      FactoryBot.create(:transaction, account: account2, date: '2015-07-01', amount: -amount)
      FactoryBot.create(:transaction, account: account2, date:, amount: 444)
      t6 = FactoryBot.create(:transaction, account: account2, date:, amount: -amount)
      t7 = FactoryBot.create(:transaction, account: account2, date:, amount: -amount, matching_transaction: t0)

      get :matching, params: { account_id: account1.id, id: t0.id }

      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['transactions'].length).to eq(3)
      expect(json['transactions'][0]['id']).to eq(t1.id)
      expect(json['transactions'][1]['id']).to eq(t6.id)
      expect(json['transactions'][2]['id']).to eq(t7.id)
    end

    it 'returns any empty list when no matching transactions are found' do
      account1 = FactoryBot.create(:account)
      t0 = FactoryBot.create(:transaction, account: account1, date: '2014-07-01', amount: 333)

      get :matching, params: { account_id: account1.id, id: t0.id }

      expect(response).to have_http_status(:ok)

      json = response.parsed_body
      expect(json['transactions'].length).to eq(0)
    end
  end
end
