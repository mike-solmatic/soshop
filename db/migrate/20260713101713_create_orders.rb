class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :seller,   null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :shipping_address, foreign_key: { to_table: :addresses }
      t.string :number,        null: false
      t.integer :status,       null: false, default: 0 # pending/processing/shipped/delivered/cancelled
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :shipping_cents, null: false, default: 0
      t.integer :total_cents,    null: false, default: 0
      t.string :currency,        null: false, default: "USD"
      t.datetime :placed_at,     null: false

      t.timestamps
    end

    add_index :orders, [ :seller_id, :number ], unique: true
    add_index :orders, [ :seller_id, :status ]
    add_index :orders, [ :seller_id, :placed_at ]
  end
end
