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

ActiveRecord::Schema[8.1].define(version: 2026_07_13_101716) do
  create_table "addresses", force: :cascade do |t|
    t.string "city", null: false
    t.string "country", default: "US", null: false
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.boolean "default", default: false, null: false
    t.string "label", default: "Home", null: false
    t.string "line1", null: false
    t.string "line2"
    t.string "phone"
    t.string "postal_code", null: false
    t.string "recipient", null: false
    t.integer "seller_id", null: false
    t.string "state"
    t.datetime "updated_at", null: false
    t.index ["customer_id", "default"], name: "index_addresses_on_customer_id_and_default"
    t.index ["customer_id"], name: "index_addresses_on_customer_id"
    t.index ["seller_id"], name: "index_addresses_on_seller_id"
  end

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.string "name", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "name", null: false
    t.string "provider", default: "facebook", null: false
    t.datetime "remember_created_at"
    t.integer "seller_id", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["seller_id", "email"], name: "index_customers_on_seller_id_and_email"
    t.index ["seller_id", "provider", "uid"], name: "index_customers_on_seller_id_and_provider_and_uid", unique: true
    t.index ["seller_id"], name: "index_customers_on_seller_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.date "due_on"
    t.date "issued_on"
    t.string "number", null: false
    t.integer "order_id", null: false
    t.integer "seller_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_invoices_on_order_id"
    t.index ["seller_id", "number"], name: "index_invoices_on_seller_id_and_number", unique: true
    t.index ["seller_id"], name: "index_invoices_on_seller_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.integer "product_id"
    t.string "product_name", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.integer "customer_id", null: false
    t.string "number", null: false
    t.datetime "placed_at", null: false
    t.integer "seller_id", null: false
    t.integer "shipping_address_id"
    t.integer "shipping_cents", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "subtotal_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["seller_id", "number"], name: "index_orders_on_seller_id_and_number", unique: true
    t.index ["seller_id", "placed_at"], name: "index_orders_on_seller_id_and_placed_at"
    t.index ["seller_id", "status"], name: "index_orders_on_seller_id_and_status"
    t.index ["seller_id"], name: "index_orders_on_seller_id"
    t.index ["shipping_address_id"], name: "index_orders_on_shipping_address_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.integer "method", default: 0, null: false
    t.integer "order_id", null: false
    t.datetime "paid_at"
    t.string "reference", null: false
    t.integer "seller_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "status"], name: "index_payments_on_order_id_and_status"
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["seller_id", "reference"], name: "index_payments_on_seller_id_and_reference", unique: true
    t.index ["seller_id"], name: "index_payments_on_seller_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "category", default: "Tote", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "price_cents", default: 0, null: false
    t.integer "seller_id", null: false
    t.datetime "updated_at", null: false
    t.index ["seller_id", "name"], name: "index_products_on_seller_id_and_name"
    t.index ["seller_id"], name: "index_products_on_seller_id"
  end

  create_table "sellers", force: :cascade do |t|
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.boolean "enabled", default: true, null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.string "store_name", null: false
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_sellers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_sellers_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_sellers_on_slug", unique: true
    t.index ["status"], name: "index_sellers_on_status"
    t.index ["unlock_token"], name: "index_sellers_on_unlock_token", unique: true
  end

  add_foreign_key "addresses", "customers"
  add_foreign_key "addresses", "sellers"
  add_foreign_key "customers", "sellers"
  add_foreign_key "invoices", "orders"
  add_foreign_key "invoices", "sellers"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "addresses", column: "shipping_address_id"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "sellers"
  add_foreign_key "payments", "orders"
  add_foreign_key "payments", "sellers"
  add_foreign_key "products", "sellers"
end
