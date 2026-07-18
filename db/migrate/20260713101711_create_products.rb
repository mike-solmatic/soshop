class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :seller, null: false, foreign_key: true
      t.string :name,        null: false
      t.string :category,    null: false, default: "Tote" # bag category
      t.text :description
      t.integer :price_cents, null: false, default: 0
      t.string :currency,     null: false, default: "USD"
      t.boolean :active,      null: false, default: true

      t.timestamps
    end

    add_index :products, [ :seller_id, :name ]
  end
end
