require 'open-uri'
require 'yajl'
include ERB::Util

class Payout < ActiveRecord::Base

  belongs_to :user

  serialize :earnings_breakdown

  after_create :send_payment

  def send_payment
    #$main_password&second_password=$second_password&to=$address&amount=$amount&from=$from&shared=$shared&fee=$fee¬e=$note
    hash = {
      password: ENV['WALLET_PASSWORD'],
      to:       user.wallet_address,
      amount:   (Rails.env.development? ? 50000 : user.total_earnings.to_i),
      note:     "#{App.name} Payout!"
    }
    # logger.info "https://blockchain.info/merchant/#{App.wallet_guid}/payment?#{hash.to_param}"
    
    if resp = Yajl::Parser.parse(open("https://blockchain.info/merchant/#{App.wallet_guid}/payment?#{hash.to_param}"))
      if resp['tx_hash']
        update_attributes(
          transaction_message:  resp['message'], 
          transaction_hash:     resp['tx_hash'], 
          transaction_notice:   resp['notice'])
        notify
      else
        errors.add(:base, "The transaction could not be validated. #{resp.inspect}")  
      end
    else
      errors.add(:base, "Blockchain.info could not be contacted.")
    end
    
  end

  def notify
    if user.payout_to_charity?
      UserMailer.notify_charity_payout(self).deliver
    else
      UserMailer.notify_user_payout(self).deliver
    end
  end

end