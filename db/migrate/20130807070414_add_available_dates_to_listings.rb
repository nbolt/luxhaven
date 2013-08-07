class AddAvailableDatesToListings < ActiveRecord::Migration
  def change
    add_column :listings, :unlisted_dates, :text
  end
end
