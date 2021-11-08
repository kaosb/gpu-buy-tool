class CreateSellers < ActiveRecord::Migration[6.1]
  def change
    create_table :sellers do |t|
      t.string :username
      t.string :stars
      t.string :feedback
      t.timestamps
      t.boolean :status, default: true
    end
  end
end
