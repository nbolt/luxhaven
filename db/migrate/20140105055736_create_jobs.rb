class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :city
      t.boolean :active
      t.string :title

      t.timestamps
    end
  end
end
