class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :name
      t.integer :address_id
      t.integer :region_id
      t.text :description

      t.timestamps
    end
  end
end
