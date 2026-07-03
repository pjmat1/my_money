# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_07_03_090000) do
  create_table "account_types", force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "accounts", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "bank", limit: 255
    t.integer "starting_balance"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.date "starting_date"
    t.integer "reconciliation_id"
    t.string "ticker", limit: 255
    t.string "account_type", limit: 255
    t.integer "limit"
    t.integer "term"
    t.decimal "interest_rate"
    t.date "deleted_at"
  end

  create_table "bank_statements", force: :cascade do |t|
    t.integer "account_id"
    t.date "date"
    t.integer "transaction_count"
    t.string "file_name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "budgets", force: :cascade do |t|
    t.integer "account_id"
    t.string "description", limit: 255
    t.integer "day_of_month"
    t.integer "amount"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "category_type_id"
  end

  create_table "category_types", force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "data_files", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "patterns", force: :cascade do |t|
    t.integer "account_id"
    t.string "match_text", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "category_id"
    t.integer "subcategory_id"
    t.string "notes", limit: 255
    t.index ["match_text"], name: "index_patterns_on_match_text"
  end

  create_table "reconciliations", force: :cascade do |t|
    t.integer "account_id"
    t.date "statement_date"
    t.integer "statement_balance"
    t.boolean "reconciled"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.date "last_reconciled_date"
    t.decimal "last_reconciled_balance"
  end

  create_table "subcategories", force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "category_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "transaction_types", force: :cascade do |t|
    t.integer "account_type_id"
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "transactions", force: :cascade do |t|
    t.string "transaction_type", limit: 255
    t.date "date"
    t.integer "amount"
    t.string "fitid", limit: 255
    t.string "memo", limit: 255
    t.integer "account_id"
    t.integer "category_id"
    t.integer "subcategory_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "notes", limit: 255
    t.integer "reconciliation_id"
    t.integer "balance"
    t.integer "unit_price"
    t.integer "quantity"
    t.integer "bank_statement_id"
    t.integer "matching_transaction_id"
  end

end
