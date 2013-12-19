class AddVenueTypeToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :venue_type, :string
  end
end
