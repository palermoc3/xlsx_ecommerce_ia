class CreateItemPurchases < ActiveRecord::Migration[8.1]
  def change
    create_table :item_purchases do |t|
      t.references :purchase, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :subtotal, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
