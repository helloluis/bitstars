class Tip < ActiveRecord::Base
  
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"

  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"

  validate :check_minimum_tip

  after_create :send_notification

  def check_minimum_tip
    errors.add(:base, "That amount is below the minimum tip of #{App.minimum_tip} BTC") if amount_in_btc < App.minimum_tip
  end

  def self.today
    self.where(["created_at>=?",Time.now.beginning_of_day])
  end

  def self.today_amount
    self.where(["created_at>=?",Time.now.beginning_of_day]).map(&:amount_in_btc).sum
  end

  def self.send!(sender, photo, amount_in_btc, amount_in_php)
    transaction_fee_in_btc  = amount_in_btc*App.transaction_fee_percentage
    transaction_fee_in_php  = amount_in_php*App.transaction_fee_percentage
    amount_in_btc_after_fee = amount_in_btc-transaction_fee_in_btc
    amount_in_php_after_fee = amount_in_php-transaction_fee_in_php
    
    photo.tips.create(  sender:           sender, 
                        recipient:        photo.user, 
                        transaction_fee:  transaction_fee_in_btc,
                        amount_in_btc:    amount_in_btc_after_fee, 
                        amount_in_php:    amount_in_php_after_fee )

    total_tips = photo.user.total_tips
    total_earnings = photo.user.total_earnings 
    
    photo.user.update_attributes(
      total_tips:     total_tips + amount_in_btc_after_fee, 
      total_earnings: total_earnings + amount_in_btc_after_fee)
  end

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

end