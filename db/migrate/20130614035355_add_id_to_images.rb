class AddIdToImages < ActiveRecord::Migration
  def change
    add_column :images, :listing_id, :integer
  end
end
