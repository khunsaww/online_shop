class CreateCarts < ActiveRecord::Migration[7.1]
  def change
    create_table :carts do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :fulfillment_method_id

      t.timestamps
    end
  end
end
