class CreateParagraphImages < ActiveRecord::Migration
  def change
    create_table :paragraph_images do |t|
      t.integer :paragraph_id
      t.string  :image
      t.string  :align
      t.string  :version
      t.string  :caption

      t.timestamps
    end
  end
end
