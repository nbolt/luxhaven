class AddRegionToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :region_id, :integer
  end
end
