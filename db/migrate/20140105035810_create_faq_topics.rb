class CreateFaqTopics < ActiveRecord::Migration
  def change
    create_table :faq_topics do |t|
      t.string :title
      t.integer :faq_section_id

      t.timestamps
    end
  end
end
