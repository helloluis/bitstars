class Payout < ActiveRecord::Base

  belongs_to :user

  serialize :earnings_breakdown

  after_create :notify

  def notify
    if user.payout_to_charity?
      UserMailer.notify_user_payout(self).deliver
    else
      UserMailer.notify_charity_payout(self).deliver
    end
  end

end