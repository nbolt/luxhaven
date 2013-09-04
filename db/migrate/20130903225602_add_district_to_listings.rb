class AddDistrictToListings < ActiveRecord::Migration
  def change
    add_column :listings, :district_id, :integer
  end
end
