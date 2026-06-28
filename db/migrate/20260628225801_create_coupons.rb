class CreateCoupons < ActiveRecord::Migration[8.1]
  def change
    create_table :coupons do |t|
      t.string :code, null: false
      t.string :discount_type, null: false
      t.decimal :discount_value, precision: 10, scale: 2, null: false
      t.boolean :active, null: false, default: true
      t.datetime :expires_at

      t.timestamps
    end

    add_index :coupons, :code, unique: true
  end
end
