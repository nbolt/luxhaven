class AddAmenitiesToListings < ActiveRecord::Migration
  def change
    add_column :listings, :garden, :boolean
    add_column :listings, :balcony, :boolean
    add_column :listings, :parking, :integer
    add_column :listings, :smoking, :boolean
    add_column :listings, :pets, :boolean
    add_column :listings, :children, :boolean
    add_column :listings, :babies, :boolean
    add_column :listings, :toddlers, :boolean
    add_column :listings, :tv, :boolean
    add_column :listings, :temp_control, :boolean
    add_column :listings, :pool, :boolean
    add_column :listings, :jacuzzi, :boolean
    add_column :listings, :washer, :boolean
  end
end
