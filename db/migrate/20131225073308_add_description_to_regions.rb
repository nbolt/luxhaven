class AddDescriptionToRegions < ActiveRecord::Migration
  def change
    add_column :regions, :getting_around, :text
    add_column :regions, :description, :text
    add_column :regions, :tagline, :text
  end
end
