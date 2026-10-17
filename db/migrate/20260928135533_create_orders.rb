class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :fulfillment_method_id, null: false
      t.integer :status_id, null: false
      t.integer :total_price, null: false
      t.datetime :ordered_at, null: false

      t.timestamps
    end
  end
end
