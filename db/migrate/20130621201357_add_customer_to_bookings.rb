class AddCustomerToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :customer_id, :string
  end
end
