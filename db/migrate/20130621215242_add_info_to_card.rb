class AddInfoToCard < ActiveRecord::Migration
  def change
    add_column :cards, :last4, :string
    add_column :cards, :fingerprint, :string
  end
end
