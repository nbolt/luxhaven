class AddTravelToNeighborhoods < ActiveRecord::Migration
  def change
    add_column :neighborhoods, :public_transport, :boolean
    add_column :neighborhoods, :driving, :boolean
  end
end
