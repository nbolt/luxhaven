class AddIndexToListings < ActiveRecord::Migration
  def change
    add_index :listings, :region_id
  end
end
