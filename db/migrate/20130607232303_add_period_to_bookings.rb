class AddPeriodToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :price_period, :string
  end
end
