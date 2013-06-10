class RemoveStripeIdFromBookings < ActiveRecord::Migration
  def change
    remove_column :bookings, :stripe_id, :string
  end
end
