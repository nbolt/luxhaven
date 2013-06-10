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
  end
end

every 1.day, 'bookings:process_transfers', at: '00:00'