class RemoveCardFromBookings < ActiveRecord::Migration
  def change
    remove_column :bookings, :card, :string
  end
end
