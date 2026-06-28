class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.date :birth_date, null: false
      t.string :state, null: false
      t.string :city

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
