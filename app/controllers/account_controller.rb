class AccountController < ApplicationController
  
  def index
  end

  def update
    unless current_user.stripe_recipient
      current_user.update_attribute :stripe_recipient,
        # do we want to ask for ssn?
        Stripe::Recipient.create(name: current_user.name, email: current_user.email, type: 'individual', tax_id: params[:ssn]).id
    end
    recipient = Stripe::Recipient.retrieve current_user.stripe_recipient
    recipient.bank_account = { country: 'US', routing_number: params[:routing], account_number: params[:account] }
    if recipient.save
      current_user.update_attributes(
        bank_name:        recipient.active_account.bank_name,
        bank_last4:       recipient.active_account.last4,
        bank_fingerprint: recipient.active_account.fingerprint
      )
      render json: { success: true }
    else
      render json: { success: false }
    end
  end

end
