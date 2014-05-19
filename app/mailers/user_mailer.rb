class UserMailer < ActionMailer::Base

  def notify_winner(photo)
    @photo = photo
    mail(to: @photo.user.email, subject: t(:your_selfie_is_todays_winner))
  end

  def notify_tip_sender(photo, tip)
    @photo = photo
    @tip = tip
    @sender = tip.sender
    mail(to: @sender.email, subject: t(:your_selfie_is_todays_winner))
  end

  def notify_tip_recipient(photo, tip)
    @photo = photo
    @tip = tip
    @sender = tip.sender
    mail(to: @photo.user.email, subject: t(:your_selfie_is_todays_winner))
  end

  def request_withdrawal(user)
    @user = user
    mail(to: App.emails.admin, subject: "#{user.full_name} is requesting a withdrawal of funds.")
  end
end