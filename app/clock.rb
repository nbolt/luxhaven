load 'config/boot.rb'
load 'config/environment.rb'

require 'clockwork'
include Clockwork

configure do |config|
  config[:tz] = "America/Los_Angeles"
end

handler do |job|
  case job
  when 'bookings:process_transfers'
    Booking.where(transfer_status: nil, payment_status: 'charged').each { |b| b.transfer! }
  when 'users:reset_password_tokens'
    User.where('reset_password_token is not null').each do |user|
      user.update_attribute :reset_password_token, nil if user.updated_at < 1.day.ago
    end
  end
end

every 1.day, 'bookings:process_transfers',  at: '00:00'
every 1.day, 'users:reset_password_tokens', at: '00:00'