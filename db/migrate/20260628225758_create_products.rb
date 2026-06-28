class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :cost_price, precision: 10, scale: 2, null: false
      t.integer :stock, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
