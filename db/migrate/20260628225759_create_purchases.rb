class CreatePurchases < ActiveRecord::Migration[8.1]
  def change
    create_table :purchases do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :payment_method, null: false
      t.datetime :purchase_date, null: false
      t.decimal :subtotal, precision: 10, scale: 2, null: false, default: 0
      t.decimal :shipping_cost, precision: 10, scale: 2, null: false, default: 0
      t.decimal :discount_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end
  end
end
