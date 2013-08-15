class CreateParagraphs < ActiveRecord::Migration
  def change
    create_table :paragraphs do |t|
      t.text :content
      t.integer :listing_id

      t.timestamps
    end
  end
end
