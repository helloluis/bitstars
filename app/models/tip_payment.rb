class TipPayment < ActiveRecord::Base

  serialize :payment_details

  belongs_to :tip

  belongs_to :sender, class_name: "User", foreign_key: "sender_id"

  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"

  after_create :calculate_amounts

  after_create :send_notifications

  after_create :update_photo_count

  def calculate_amounts
    raw_btc = self.payment_details[:value_in_satoshi]
    self.original_amount_in_sats = raw_btc
    self.final_amount_in_sats    = raw_btc-(raw_btc*App.transaction_fee_percentage)
    self.transaction_fee         = raw_btc*App.transaction_fee_percentage
    self.save
  end

  def update_photo_count
    tip.photo.increment!(:num_tips)
  end

  def in_mbtc
    final_amount_in_sats/100000
  end

  def in_btc
    final_amount_in_sats*100000000
  end

  def send_notifications
    UserMailer.notify_tip_sender(tip.photo, tip, self).deliver
    UserMailer.notify_tip_recipient(tip.photo, tip, self).deliver
  end
end