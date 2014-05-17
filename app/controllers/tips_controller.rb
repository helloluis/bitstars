class TipsController < ApplicationController

  def index
    @received_tips = current_user.received_tips
    @sent_tips = current_user.sent_tips
  end

end