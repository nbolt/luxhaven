class AddChargeIdToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :stripe_charge_id, :string
  end
end
