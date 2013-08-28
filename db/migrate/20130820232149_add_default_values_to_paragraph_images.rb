class AddDefaultValuesToParagraphImages < ActiveRecord::Migration
  def up
    change_column :paragraph_images, :version, :string, :default => 'side_landscape'
    change_column :paragraph_images, :align, :string, :default => 'right'
  end
  def down
    change_column :paragraph_images, :version, :string, :default => nil
    change_column :paragraph_images, :align, :string, :default => nil
  end
end
