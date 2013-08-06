class AddInfoToListings < ActiveRecord::Migration
  def change
    add_column :listings, :accomodates_from, :integer
    add_column :listings, :accomodates_to, :integer
    add_column :listings, :bedrooms, :integer
    add_column :listings, :baths, :integer
  end
end
