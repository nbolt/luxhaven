class AddCardToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_card, :string
  end
end
