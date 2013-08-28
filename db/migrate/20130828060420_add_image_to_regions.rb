class AddImageToRegions < ActiveRecord::Migration
  def change
    add_column :regions, :image, :string
  end
end
