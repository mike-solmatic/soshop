class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :seller,   null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.string :label,       null: false, default: "Home"
      t.string :recipient,   null: false
      t.string :line1,       null: false
      t.string :line2
      t.string :city,        null: false
      t.string :state
      t.string :postal_code, null: false
      t.string :country,     null: false, default: "US"
      t.string :phone
      t.boolean :default,    null: false, default: false

      t.timestamps
    end

    add_index :addresses, [ :customer_id, :default ]
  end
end
