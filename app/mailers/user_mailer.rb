class UserMailer < ActionMailer::Base
  
  default from: App.emails.support
  layout "mailer"
  helper :application

  def notify_winner(photo)
    @photo = photo
    mail(to: @photo.user.email, subject: t(:your_selfie_is_todays_winner))
  end

  def notify_tip_sender(photo, tip, payment)
    @photo = photo
    @tip = tip
    @sender = tip.sender
    @recipient = tip.recipient
    mail(to: @sender.email, subject: t(:your_tip_has_been_sent_successfully))
  end

  def notify_tip_recipient(photo, tip, payment)
    @photo = photo
    @tip = tip
    @sender = tip.sender
    @recipient = tip.recipient
    mail(to: @photo.user.email, subject: t(:youve_just_received_a_tip))
  end

  def request_withdrawal(user)
    @user = user
    mail(to: App.emails.admin, subject: "#{user.full_name} is requesting a withdrawal of funds.")
  end
end