class AddListingToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :listing_id, :integer
  end
end
