class AddPriceToListings < ActiveRecord::Migration
  def change
    add_column :listings, :price_per_night, :integer
    add_column :listings, :price_per_week, :integer
    add_column :listings, :price_per_month, :integer
  end
end
