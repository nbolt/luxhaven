class AddVenueDescriptionsToRegions < ActiveRecord::Migration
  def change
    add_column :regions, :attractions_description, :text
    add_column :regions, :cafes_description, :text
    add_column :regions, :nightlife_description, :text
    add_column :regions, :shopping_description, :text
  end
end
