require 'open-uri'
require 'yajl'
include ERB::Util

class Tip < ActiveRecord::Base

  serialize :payment_details, Array

  belongs_to :sender, class_name: "User", foreign_key: "sender_id"

  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"

  belongs_to :photo

  has_many :tip_payments

  validate :check_minimum_tip
  validate :check_eligibility

  def check_minimum_tip
    errors.add(:base, "That amount is below the minimum tip of #{App.minimum_tip} BTC") if amount_in_btc < App.minimum_tip
  end

  def check_eligibility
    errors.add(:base, "The recipient hasn't completed their profile yet and is not eligible for tips.") unless recipient.has_completed_profile?
  end

  def self.today
    self.where(["created_at>=?",Time.now.beginning_of_day])
  end

  def self.today_amount
    self.where(["created_at>=?",Time.now.beginning_of_day]).map(&:actual_amount_in_sats).sum
  end

  def generate_invoice_address!(force=false)
    if invoice_address.blank? || force==true
      callback_url = url_encode("http://#{App.url}/tips/#{id}/callback_for_blockchain")
      if resp = Yajl::Parser.parse(open("https://blockchain.info/api/receive?method=create&address=#{App.wallet_address}&callback=#{callback_url}"))
        self.invoice_address = resp['input_address']
      end
    end
  end

  def invoice_address_with_amount
    "bitcoin:#{invoice_address}?amount=#{amount_in_btc}&#{App.wallet_address_params}"
  end

  def total_payments
    total = tip_payments.map(&:final_amount_in_sats).sum
    total
  end

  def add_payment_details!(hash)
    return false if self.tip_payments.where(transaction_hash: hash[:transaction_hash]).exists?
    payment = self.tip_payments.create( sender: sender, 
                                        recipient: recipient, 
                                        payment_details: hash, 
                                        transaction_hash: hash[:transaction_hash])
    self.update_attributes(:actual_amount_in_sats => total_payments)
    self.success!
    self.sender.calculate_total_tips_sent!
    self.recipient.increment!(:num_tips)
    self.recipient.calculate_total_earnings!(payment.final_amount_in_sats)
  end

  def pending?
    status==0
  end

  def successful?
    status==1
  end

  def success!
    update_attributes(status: 1, paid: true)
  end

  def status_in_words
    %w(pending successful rejected)[status]
  end

end