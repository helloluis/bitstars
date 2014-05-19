class TipPayment < ActiveRecord::Base

  serialize :payment_details, Array
  
  belongs_to :tip

  after_create :calculate_amounts

  after_create :send_notifications

  def calculate_amounts
    raw_btc = self.payment_details['value']/100000000
    self.original_amount_in_btc = raw_btc
    self.final_amount_in_btc    = raw_btc*(100-(App.transaction_fee_percentage*100))
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
    UserMailer.notify_tip_sender(photo, self).deliver
    UserMailer.notify_tip_recipient(photo, self).deliver
  end
end