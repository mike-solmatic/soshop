class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :seller, null: false, foreign_key: true
      t.references :order,  null: false, foreign_key: true
      t.string :number,       null: false
      t.integer :status,      null: false, default: 0 # draft/issued/paid/void
      t.integer :amount_cents, null: false
      t.string :currency,      null: false, default: "USD"
      t.date :issued_on
      t.date :due_on

      t.timestamps
    end

    add_index :invoices, [ :seller_id, :number ], unique: true
  end
end
