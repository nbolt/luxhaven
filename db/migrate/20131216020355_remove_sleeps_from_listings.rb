class RemoveSleepsFromListings < ActiveRecord::Migration
  def change
    remove_column :listings, :sleeps, :integer
  end
end
