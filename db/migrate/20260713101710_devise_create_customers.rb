class DeviseCreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      # Tenant
      t.references :seller, null: false, foreign_key: true

      # Facebook Connect profile
      t.string :provider,   null: false, default: "facebook"
      t.string :uid,        null: false
      t.string :name,       null: false
      t.string :email
      t.string :avatar_url

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.timestamps null: false
    end

    # A Facebook user is a distinct customer record per seller (tenant-scoped)
    add_index :customers, [ :seller_id, :provider, :uid ], unique: true
    add_index :customers, [ :seller_id, :email ]
  end
end
