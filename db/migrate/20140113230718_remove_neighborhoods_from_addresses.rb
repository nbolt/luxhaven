class RemoveNeighborhoodsFromAddresses < ActiveRecord::Migration
  def change
    remove_column :addresses, :neighborhood, :string
  end
end
