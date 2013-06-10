class AddRecipientToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_recipient, :string
  end
end
