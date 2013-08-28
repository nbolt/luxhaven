class AddDefaultValuesToParagraphs < ActiveRecord::Migration
  def up
    change_column :paragraphs, :order, :integer, :default => 0
  end
  def down
    change_column :paragraphs, :order, :integer, :default => nil
  end
end