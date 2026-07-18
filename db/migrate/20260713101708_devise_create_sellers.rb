class DeviseCreateSellers < ActiveRecord::Migration[8.1]
  def change
    create_table :sellers do |t|
      t.string :name,       null: false
      t.string :store_name, null: false
      t.string :slug,       null: false
      t.integer :status,    null: false, default: 0 # 0=pending, 1=approved
      t.boolean :enabled,   null: false, default: true
      t.datetime :approved_at

      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token
      t.datetime :locked_at

      t.timestamps null: false
    end

    add_index :sellers, :email,                unique: true
    add_index :sellers, :slug,                 unique: true
    add_index :sellers, :reset_password_token, unique: true
    add_index :sellers, :unlock_token,         unique: true
    add_index :sellers, :status
  end
end
