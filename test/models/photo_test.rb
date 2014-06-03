require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  include ActionView::Helpers::NumberHelper

  def setup
    @user = FactoryGirl.create(:user)
    @photo = FactoryGirl.create(:photo)
    @photo.update_attributes(user: @user)
  end
  
  test "should only allow #{App.max_submissions_per_day} photos per day" do
    @max_photos = []
    @max_user = FactoryGirl.create(:user)
    4.times.each do |i|
      @max_user.reload
      photo = FactoryGirl.build(:photo)
      photo.user = @max_user 
      photo.save
      @max_photos << photo if photo.valid?
    end
    assert @max_photos.length==App.max_submissions_per_day, "#{@max_photos.length} of max #{App.max_submissions_per_day} photos created"
  end

  test "should increment user total winnings by #{App.prize_tiers.first.last} if photo wins" do 
    @prev_winnings = @user.total_winnings
    @photo.win!
    assert @user.total_winnings == App.prize_tiers.first.last, "CURRENT: #{@user.total_winnings} PREVIOUS: #{@prev_winnings}"
  end

  test "should only award #{App.prize_tiers.first.last} pesos if there are fewer than #{App.prize_tiers.first.first.max} submissions today" do
    App.prize_tiers.first.first.min.times.each do |i|
      FactoryGirl.create(:photo)
    end
    assert Prize.daily_prize_amount(Time.now.strftime("%Y-%m-%d"))==App.prize_tiers.first.last, "Prize: #{Prize.daily_prize_amount(Time.now.strftime("%Y-%m-%d"))}"
  end

  test "should award #{App.prize_tiers[1].last} pesos if there are more than #{App.prize_tiers.first.first.max} submissions today" do
    App.prize_tiers.first.first.max.times.each do |i|
      FactoryGirl.create(:photo)
    end
    assert Prize.daily_prize_amount(Time.now.strftime("%Y-%m-%d"))==App.prize_tiers[1].last, "Prize: #{Prize.daily_prize_amount(Time.now.strftime("%Y-%m-%d"))}"
  end

  test "should award #{App.prize_tiers.last.last} pesos if there are more than #{App.prize_tiers.last.first.max} submissions today" do 
    101.times.each do |i|
      FactoryGirl.create(:photo)
    end
    assert Prize.daily_prize_amount(Time.now.strftime("%Y-%m-%d"))==App.prize_tiers.last.last, "Prize: #{Prize.daily_prize_amount(Time.now.strftime("%Y-%m-%d"))}"
  end

  test "should award #{App.prize_tiers.first.last} pesos in satoshis to a given user if there are less than #{App.prize_tiers.first.first.max} submissions today" do 
    @photos = []
    11.times.each do |i|
      @photos << FactoryGirl.create(:photo)
    end
    @winning_photo = @photos.last
    @winning_photo.user = FactoryGirl.create(:user)
    @winning_photo.win!
    @prize_in_sats = Prize.daily_prize_amount(Time.now.strftime("%Y-%m-%d"))
    @php = to_php(@winning_photo.user.total_winnings,true)
    assert @prize_in_sats==@php.to_i, "Correct Prize in Pesos: #{@prize_in_sats} Final Prize in Pesos: #{@php}"
  end

  test "should award #{App.prize_tiers.last.last} pesos in satoshis to a given user if there are more than #{App.prize_tiers.last.first.max} submissions today" do 
    @photos = []
    101.times.each do |i|
      @photos << FactoryGirl.create(:photo)
    end
    @winning_photo = @photos.last
    @winning_photo.user = FactoryGirl.create(:user)
    @winning_photo.win!
    @prize_in_sats = Prize.daily_prize_amount(Time.now.strftime("%Y-%m-%d"))
    @php = to_php(@winning_photo.user.total_winnings,true)
    assert @prize_in_sats==@php.to_i, "Correct Prize in Pesos: #{@prize_in_sats} Final Prize in Pesos: #{@php}"
  end
end
