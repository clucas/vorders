class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :name
      t.string :reason
      t.string :status
      t.date :order_on, :null => false

      t.timestamps
    end
  end
end
