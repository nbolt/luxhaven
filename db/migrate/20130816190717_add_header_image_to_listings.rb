class AddHeaderImageToListings < ActiveRecord::Migration
  def change
    add_column :listings, :header_image, :string
  end
end
