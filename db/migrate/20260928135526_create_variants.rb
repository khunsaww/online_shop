class CreateVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :variants do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :option_kind_id, null: false
      t.string :label, null: false
      t.integer :price, null: false
      t.integer :stock, null: false, default: 0

      t.timestamps
    end
  end
end
