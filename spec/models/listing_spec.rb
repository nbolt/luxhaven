require 'spec_helper'

describe Listing do
  subject    { listing }
  let(:listing) { Listing.new(slug: 'test') }

  it 'detects conflicts correctly' do
    listing.address = Address.create
    listing.address.region = Region.create
    listing.save!

    listing.bookings.create(
      check_in: Date.today,
      check_out: Date.today + 7.days,
      payment_status: 'charged'
    )

    listing.bookings.create(
      check_in: Date.today - 7.days,
      check_out: Date.today - 4.days,
      payment_status: 'charged'
    )

    listing.bookings.create(
      check_in: Date.today + 14.days,
      check_out: Date.today + 21.days,
      payment_status: 'charged'
    )

    listing.conflicts?(Date.today + 7.days, Date.today + 8.days).should eq(false)
  end

  it 'detects availability correctly' do
    Listing.available(Date.today + 7.days, Date.today + 8.days, [listing]).should have(1).listings
  end

  it { should belong_to(:user) }
  it { should belong_to(:region) }
  it { should have_one(:address) }
end