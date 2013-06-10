class AddTransferIdToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :stripe_transfer_id, :string
  end
end
