class UserMailer < ActionMailer::Base
  
  default from: App.emails.admin
  layout "mailer"
  helper :application

  def notify_admin(photo)
    @photo = photo
    mail(to: App.emails.admin, subject: "New Selfie from #{@photo.user.full_name}!")
  end

  def notify_winner(photo)
    @photo = photo
    mail(to: @photo.user.email, subject: t(:your_selfie_is_todays_winner))
  end

  def notify_tip_sender(photo, tip, payment)
    @photo     = photo
    @tip       = tip
    @payment   = payment
    @sender    = tip.sender
    @recipient = tip.recipient
    mail(to: @sender.email, subject: "#{App.name}: #{t(:your_tip_has_been_sent_successfully)}" )
  end

  def notify_tip_recipient(photo, tip, payment)
    @photo     = photo
    @tip       = tip
    @payment   = payment
    @sender    = tip.sender
    @recipient = tip.recipient
    mail(to: @photo.user.email, subject: "#{App.name}: #{t(:youve_just_received_a_tip)}" )
  end

  def notify_charity_payout(payout)
    @user = payout.user
    @breakdown = payout.earnings_breakdown
    mail(to: @user.email, subject:"#{App.name}: #{t(:your_earnings_are_now_being_donated_to_your_selected_charity)}")
  end

  def notify_user_payout(payout)
    @user = payout.user
    @breakdown = payout.earnings_breakdown
    mail(to: @user.email, subject:"#{App.name}: #{t(:your_earnings_have_been_sent_to_your_wallet_address)}")
  end

  def request_withdrawal(user)
    @user = user
    mail(to: App.emails.admin, subject: "#{user.full_name} is requesting a withdrawal of funds.")
  end

  def report_content(photo, user)
    @user = user
    @photo = photo
    mail(to: App.emails.admin, subject: "#{user.full_name} is reporting Content ##{photo.id}")
  end
end