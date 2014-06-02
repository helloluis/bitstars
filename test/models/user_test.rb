require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # include Devise::TestHelpers

  def setup
    @user = FactoryGirl.create(:user)
  end
  
  test "should create new user" do
    assert @user
  end
end
