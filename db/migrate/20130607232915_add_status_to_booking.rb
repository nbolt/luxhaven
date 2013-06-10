class AddStatusToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :payment_status, :string
  end
end
