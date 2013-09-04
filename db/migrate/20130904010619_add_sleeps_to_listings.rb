class AddSleepsToListings < ActiveRecord::Migration
  def change
    add_column :listings, :sleeps, :integer
  end
end
