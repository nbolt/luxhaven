class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :stripe_id
      t.references :user

      t.timestamps
    end
  end
end
