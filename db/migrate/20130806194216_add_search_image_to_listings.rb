class AddSearchImageToListings < ActiveRecord::Migration
  def change
    add_column :listings, :search_image, :string
  end
end
