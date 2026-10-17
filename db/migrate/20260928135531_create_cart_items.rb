class CreateCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :variant, null: false, foreign_key: true
      t.integer :quantity, null: false

      t.timestamps
    end
    add_index :cart_items, [:cart_id, :variant_id], unique: true
  end
end
