class RemoveRegionFromVenues < ActiveRecord::Migration
  def change
    remove_column :venues, :region_id, :integer
  end
end
