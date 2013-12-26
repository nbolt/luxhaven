class AddHighlightToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :highlight, :bool
  end
end
