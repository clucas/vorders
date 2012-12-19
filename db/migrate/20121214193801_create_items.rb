class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :quantity, :null => false, :default => 1
      t.references :order
      t.references :product

      t.timestamps
    end
    add_index :items, :order_id
    add_index :items, :product_id
    add_index :items, [:order_id, :product_id], :unique => true
  end
end
