require 'spec_helper'

describe Booking do
  subject { booking }
  let(:booking) { Booking.new }

  before(:each) do
    booking.check_in  = Date.today
    booking.check_out = Date.today + 28.days

    region  = Region.create
    address = Address.new
    address.region = region
    address.save

    listing = Listing.new(title: 'test')
    listing.address = address
    booking.listing = listing
    booking.listing.price_per_night = 100

    booking.user = User.new(email: 'test@luxhaven.co')
    booking.listing.user = User.new
  end

  it 'saves correctly' do
    booking.listing.save!
    booking.save!

    booking.listing.region_id.should_not eq(nil)
  end

  #describe 'price total' do
  #  it 'calculates correctly for nightly' do
  #    booking.listing.price_per_night = 100
  #    booking.price_total.should eq(2800)
  #  end

  #  it 'calculates correctly for weekly' do
  #    booking.listing.price_per_week = 600
  #    booking.price_total.should eq(2400)
  #  end

  #  it 'calculates correctly for monthly' do
  #   booking.listing.price_per_month = 2000
  #    booking.price_total.should eq(2000)
  #  end
  #end

  describe 'booking process' do
    it 'books successfully' do
      card = {
        number: '4242424242424242',
        exp_month: 12,
        exp_year: 20
      }
      customer = Stripe::Customer.create(card: card)
      booking.customer_id = customer.id
      rsp = booking.book!
      rsp.should be_instance_of(Stripe::Charge)
      booking.payment_status.should eq('charged')
      booking.stripe_charge_id.should eq(rsp.id)
    end

    it 'responds with a booking error instance correctly' do
      booking.payment_status = 'charged'
      booking.book!.should be_instance_of(BookingError)
    end
  end

  describe 'transfer process' do
    before(:each) do
      booking.check_in  = Date.today - 1.month
      booking.check_out = Date.today - 1.day
      booking.listing.user.stripe_recipient = 'rp_1zM8yMGWtOVcVu'
    end

    it 'transfers successfully' do
      rsp = booking.transfer!
      rsp.should be_instance_of(Stripe::Transfer)
      booking.transfer_status.should eq('pending')
      booking.stripe_transfer_id.should eq(rsp.id)
    end

    it 'responds with a booking error when host has no bank details' do
      booking.listing.user.stripe_recipient = nil
      rsp = booking.transfer!
      rsp.should be_instance_of(BookingError)
    end

    it 'responds with a booking error when check out date has not transpired' do
      booking.check_in  = Date.today + 1.month
      booking.check_out = Date.today + 2.months
      rsp = booking.transfer!
      rsp.should be_instance_of(BookingError)
    end

    it 'responds with a booking error when transfer status exists' do
      booking.transfer_status = 'pending'
      rsp = booking.transfer!
      rsp.should be_instance_of(BookingError)
    end
  end

  it { should belong_to(:user) }
  it { should belong_to(:listing) }
end
