class AddTravelToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :time, :integer
    add_column :venues, :public_transit, :boolean
    add_column :venues, :traffic, :boolean
  end
end
