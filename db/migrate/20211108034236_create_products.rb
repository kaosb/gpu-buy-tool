class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :title
      t.string :url
      t.string :img
      t.string :price
      t.string :bids
      t.string :time_left
      t.string :shipping
      t.string :item_id
      t.string :seller_id
      t.string :model_id
      t.string :brand_id
      t.timestamps
      t.boolean :status, default: true
    end
  end
end
