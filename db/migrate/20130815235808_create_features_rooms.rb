class CreateFeaturesRooms < ActiveRecord::Migration
  def change
    create_table :features_rooms, id: false do |t|
      t.integer :feature_id
      t.integer :room_id
    end
  end
end
