class AddCardTypeToCards < ActiveRecord::Migration
  def change
    add_column :cards, :card_type, :string
  end
end
