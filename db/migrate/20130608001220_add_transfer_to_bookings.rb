class AddTransferToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :transfer_status, :string
  end
end
