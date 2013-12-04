class AddSearchToListings < ActiveRecord::Migration
  def change
    add_column :listings, :search_description, :text
  end
end
