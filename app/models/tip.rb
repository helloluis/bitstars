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
    self.where(["created_at>=?",Time.now.beginning_of_day]).map(&:actual_amount_in_btc).sum
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
        self.invoice_address = resp['input_address']
      end
    end
  end

  def invoice_address_with_amount
    "bitcoin:#{invoice_address}?amount=#{amount_in_btc}"
  end

  def total_payments
    total = tip_payments.map(&:final_amount_in_btc).sum
    total
  end

  def check_for_total_payments
    success! if total_payments>=total_in_btc
  end

  def add_payment_details!(hash)
    self.tip_payments.create(sender: sender, recipient: recipient, photo: photo, payment_details: hash)
    self.update_attributes(:actual_amount_in_btc => total_payments)
    self.success!
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