class AddRegionsToImages < ActiveRecord::Migration
  def change
    add_column :images, :region_id, :integer
  end
end
