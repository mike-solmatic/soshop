class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :seller, null: false, foreign_key: true
      t.references :order,  null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.string :currency,      null: false, default: "USD"
      t.integer :method,       null: false, default: 0 # card/bank_transfer/cash_on_delivery/wallet
      t.integer :status,       null: false, default: 0 # pending/succeeded/failed/refunded
      t.string :reference,     null: false
      t.datetime :paid_at

      t.timestamps
    end

    add_index :payments, [ :seller_id, :reference ], unique: true
    add_index :payments, [ :order_id, :status ]
  end
end
