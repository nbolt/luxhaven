class AddOrderToParagraphs < ActiveRecord::Migration
  def change
    add_column :paragraphs, :order, :integer
  end
end
