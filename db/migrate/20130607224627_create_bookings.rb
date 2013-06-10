class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.integer :listing_id
      t.integer :user_id
      t.string :stripe_id
      t.date :check_in
      t.date :check_out

      t.timestamps
    end
  end
end
