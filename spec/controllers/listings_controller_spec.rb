require 'spec_helper'

describe ListingsController do

  before(:each) do
    Region.create(name: 'los-angeles')
    listing = Listing.new(slug: 'test', price_per_night: 50000)
    listing.address = Address.create
    listing.address.region = Region.first
    listing.save
  end

  describe 'admin' do
    context 'GET' do
      it 'redirects if unauthorized' do
        stub(controller).current_user { User.new }
        expect(get :admin).to redirect_to('/')
      end
    end
  end

  describe 'book' do
    context 'POST' do
      it 'books successfully' do
        stub(controller).current_user { User.new(email: 'test@email.com') }
        post :book, {
          check_in: '01/01/2014',
          check_out: '01/07/2014',
          city: 'los-angeles',
          listing_slug: 'test',
          card: {
            number: '4242424242424242',
            exp_month: 12,
            exp_year: 20
          }
        }
        expect(JSON.parse(response.body)['success']).to eq(true)
      end
    end
  end

  describe 'update' do
    context 'PATCH' do
      it 'updates successfully' do
        stub(controller).current_user { User.new(admin: true) }

        request.env['RAW_POST_DATA'] = {
          listing_updates: {
            title: 'New Title',
            address: {
              street1: '1 Moon Ave.'
            }
          }
        }.to_json

        patch :update, { city: 'los-angeles', listing_slug: 'test' }

        controller.listing.title.should eq('New Title')
        controller.listing.address.street1.should eq('1 Moon Ave.')
      end
    end
  end

end