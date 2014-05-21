class Prize < ActiveRecord::Base

  belongs_to :user

  belongs_to :photo

  after_initialize :init_default_values

  after_create :calculate_user_totals

  after_create :notify

  def init_default_values
    self.amount_in_sats = CurrencyExchangeRates.convert(App.daily_prize_in_php, 'PHP', 'BTC') * 100000000
  end

  def notify
    UserMailer.notify_winner(self.photo).deliver
  end

  def calculate_user_totals
    self.user.calculate_total_earnings!
  end

  def revoke!
    update_attributes(revoked: false)
    current_total_winnings = self.user.total_winnings
    current_total_earnings = self.user.total_earnings
    self.user.update_attributes(total_winnings: current_total_winnings-amount_in_sats, total_earnings: current_total_earnings-amount_in_sats)
  end

end