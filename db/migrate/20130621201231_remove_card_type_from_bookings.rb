class RemoveCardTypeFromBookings < ActiveRecord::Migration
  def change
    remove_column :bookings, :card_type, :string
  end
end
