class AddCardInfoToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :card_type, :string
    add_column :bookings, :card, :string
  end
end
