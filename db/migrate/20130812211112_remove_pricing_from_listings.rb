class RemovePricingFromListings < ActiveRecord::Migration
  def change
    remove_column :listings, :price_per_week, :integer
    remove_column :listings, :price_per_month, :integer
    remove_column :bookings, :price_period, :string
  end
end
