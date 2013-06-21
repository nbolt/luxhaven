class RemoveStripeCardFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :stripe_card, :string
  end
end
