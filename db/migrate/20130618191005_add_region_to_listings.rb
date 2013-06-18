class AddRegionToListings < ActiveRecord::Migration
  def change
    add_column :listings, :region_id, :integer
  end
end
