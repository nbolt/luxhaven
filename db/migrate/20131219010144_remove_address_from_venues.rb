class RemoveAddressFromVenues < ActiveRecord::Migration
  def change
    remove_column :venues, :address_id, :integer
  end
end
