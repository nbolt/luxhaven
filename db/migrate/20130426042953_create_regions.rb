class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :name
      t.references :listing
      t.timestamps
    end
  end
end
