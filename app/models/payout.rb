require 'open-uri'
require 'yajl'
include ERB::Util

class Payout < ActiveRecord::Base

  belongs_to :user

  serialize :earnings_breakdown

  after_create :notify

  def send_payment
    #Yajl::Parser.parse(open("https://blockchain.info/merchant/$guid/payment?password=$main_password&second_password=$second_password&to=$address&amount=$amount&from=$from&shared=$shared&fee=$fee¬e=$note"))
  end

  def notify
    if user.payout_to_charity?
      UserMailer.notify_user_payout(self).deliver
    else
      UserMailer.notify_charity_payout(self).deliver
    end
  end

end