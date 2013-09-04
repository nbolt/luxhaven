class AddRegionToDistricts < ActiveRecord::Migration
  def change
    add_column :districts, :region_id, :integer
  end
end
