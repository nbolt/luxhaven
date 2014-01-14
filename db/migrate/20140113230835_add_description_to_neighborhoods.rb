class AddDescriptionToNeighborhoods < ActiveRecord::Migration
  def change
    add_column :neighborhoods, :description, :text
  end
end
