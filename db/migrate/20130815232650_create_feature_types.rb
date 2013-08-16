class CreateFeatureTypes < ActiveRecord::Migration
  def change
    create_table :feature_types do |t|
      t.integer :feature_id
      t.string :color
      t.string :name

      t.timestamps
    end
  end
end
