Rails.application.routes.draw do
  root 'my_money#my_money'

  namespace :api do
    resources :category_types, only: [:index]
    resources :category_type2, only: [:index]
    resources :transaction_types, only: [:index]
    resources :account_types, only: [:index]
    resources :date_range_options

    resources :subcategories
    resources :categories

    resources :accounts, only: [:create, :index, :destroy, :update] do
      member do
        post 'deactivate'
        post 'reactivate'
      end
      resources :reconciliations
      resources :bank_statements, only: [:create, :index, :destroy]
      resources :budgets, only: [:create, :index, :destroy, :update]
      resources :transactions do
        member do
          get 'matching'
        end
        collection do
          get 'unreconciled'
          post 'import'
          post 'ofx'
        end
      end
      resources :patterns
    end

    # report routes
    get 'report/income_vs_expense'
    get 'report/income_expense_bar'
    get 'report/subcategory'
    get 'report/category'
    get 'report/eod_balance'
    get 'report/net_balance'
    get 'report/home_loan'
    get 'report/recurring_payments'
    get 'report/index'
  end

  get '*path', to: 'my_money#my_money', via: :all
end
