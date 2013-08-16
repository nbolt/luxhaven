class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.integer :feature_group_id
      t.string :name

      t.timestamps
    end
  end
end
