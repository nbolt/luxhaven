class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.integer :listing_id
      t.string :name

      t.timestamps
    end
  end
end
