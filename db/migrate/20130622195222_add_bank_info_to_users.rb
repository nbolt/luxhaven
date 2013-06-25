class AddBankInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bank_name, :string
    add_column :users, :bank_last4, :string
    add_column :users, :bank_fingerprint, :string
  end
end
