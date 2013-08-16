class AddRoomToImage < ActiveRecord::Migration
  def change
    add_column :images, :room_id, :integer
  end
end
