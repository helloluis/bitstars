class Prize < ActiveRecord::Base

  belongs_to :user

  belongs_to :photo

  after_create :calculate_user_totals

  after_create :notify

  def notify
    UserMailer.notify_winner(self.photo).deliver
  end

  def calculate_user_totals
    self.user.calculate_total_earnings!(0,self.amount_in_sats)
  end

  def revoke!
    
    update_attributes(revoked: true)
    
    current_total_winnings = self.user.total_winnings
    current_total_earnings = self.user.total_earnings

    self.user.update_attributes(
      total_winnings: current_total_winnings-amount_in_sats, 
      total_earnings: current_total_earnings-amount_in_sats,
      lifetime_winnings: current_total_winnings-amount_in_sats,
      lifetime_earnings: current_total_earnings-amount_in_sats)
    
  end

  def self.daily_prize_amount(date) # strftime("%Y-%m-%d")
    photo_count = Photo.by_date(date).count
    self.daily_prize_amount_from_count(photo_count)
  end

  def self.daily_prize_amount_from_count(photo_count)
    if tier = App.prize_tiers.find{|pt| pt.first.include?(photo_count)}
      tier.last
    else
      App.prize_tiers.last.last
    end
  end
end