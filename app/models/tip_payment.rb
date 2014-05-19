class TipPayment < ActiveRecord::Base

  serialize :payment_details

  belongs_to :tip

  belongs_to :sender, class_name: "User", foreign_key: "sender_id"

  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"

  after_create :calculate_amounts

  after_create :send_notifications

  def calculate_amounts
    raw_btc = self.payment_details[:value_in_btc]
    self.original_amount_in_btc = raw_btc
    self.final_amount_in_btc    = raw_btc-(raw_btc*App.transaction_fee_percentage)
    self.transaction_fee        = raw_btc*App.transaction_fee_percentage
    self.save
  end

  # def forward_payment_to_user_wallet
  #   unless tip.recipient.wallet_address.blank?
  #     # TODO: send money using Blockchain.info Wallet API

  #     update_attributes(paid_out: true)
  #     send_notifications
  #   end
  # end

  def send_notifications
    UserMailer.notify_tip_sender(tip.photo, tip, self).deliver
    UserMailer.notify_tip_recipient(tip.photo, tip, self).deliver
  end
end