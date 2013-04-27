require 'spec_helper'

describe User do
  subject    { user }
  let(:user) { User.new }

  it 'should save info successfully' do
    user.password = 'test'
    user.password_confirmation = 'test'
    user.email = 'email'
    user.firstname = 'firstname'
    user.lastname  = 'lastname'

    user.save.should be_true
  end

  it { should have_many(:listings) }
end