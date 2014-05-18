class Tip < ActiveRecord::Base
  
  serialize :payment_details, Array

  belongs_to :sender, class_name: "User", foreign_key: "sender_id"

  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"

  validate :check_minimum_tip

  before_create :generate_invoice_address!

  # after_create :send_notification

  def check_minimum_tip
    errors.add(:base, "That amount is below the minimum tip of #{App.minimum_tip} BTC") if amount_in_btc < App.minimum_tip
  end

  def self.today
    self.where(["created_at>=?",Time.now.beginning_of_day])
  end

  def self.today_amount
    self.where(["created_at>=?",Time.now.beginning_of_day]).map(&:amount_in_btc).sum
  end

  # def self.send!(sender, photo, amount_in_btc, amount_in_php)
  #   transaction_fee_in_btc  = amount_in_btc*App.transaction_fee_percentage
  #   transaction_fee_in_php  = amount_in_php*App.transaction_fee_percentage
  #   amount_in_btc_after_fee = amount_in_btc-transaction_fee_in_btc
  #   amount_in_php_after_fee = amount_in_php-transaction_fee_in_php
    
  #   photo.tips.create(  sender:           sender, 
  #                       recipient:        photo.user, 
  #                       transaction_fee:  transaction_fee_in_btc,
  #                       amount_in_btc:    amount_in_btc_after_fee, 
  #                       amount_in_php:    amount_in_php_after_fee )

  #   total_tips = photo.user.total_tips
  #   total_earnings = photo.user.total_earnings 
    
  #   photo.user.update_attributes(
  #     total_tips:     total_tips + amount_in_btc_after_fee, 
  #     total_earnings: total_earnings + amount_in_btc_after_fee)
  # end

  def send_notification
    UserMailer.notify_tip_sender(photo, self).deliver
    UserMailer.notify_tip_recipient(photo, self).deliver
  end

  def in_mbtc
    amount_in_btc/1000
  end

  def in_microbtc
    amount_in_btc/1000000
  end

  def in_satoshis
    amount_in_btc/100000000
    # 0.000 000 01
  end

  def generate_invoice_address!(force=false)
    if invoice_address.blank? || force==true
      callback_url = url_encode("http://#{App.url}/tips/#{id}/callback_for_blockchain")
      if resp = Yajl::Parser.parse(open("https://blockchain.info/api/receive?method=create&address=#{App.wallet}&callback=#{callback_url}"))
        update_attributes(:invoice_address => resp['input_address'])
      end
    end
    invoice_address
  end

  def invoice_address_with_amount
    "bitcoin:#{invoice_address}?amount=#{amount_in_btc}"
  end

  def total_payments
    total = self.payment_details.map{|p| p[:value_in_btc] }.sum
    total
  end

  def check_for_total_payments
    success! if total_payments>=total_in_btc
  end

  def add_payment_details!(hash)
    self.payment_details << hash
    self.update_attributes(actual_amount_in_btc: total_payments)
    self.save
    self.check_for_total_payments
  end

  def pending?
    status==0
  end

  def successful?
    status==1
  end

  def status_in_words
    %w(pending successful rejected)[status]
  end

end