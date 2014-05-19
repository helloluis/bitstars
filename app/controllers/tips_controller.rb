class TipsController < ApplicationController

  def index
    @received_tips = current_user.received_tips
    @sent_tips = current_user.sent_tips
  end

  def create
    @tip = Tip.new(params[:tip].merge(sender_id: current_user.id).permit!)
    respond_to do |format|
      format.json do 
        if @tip.valid? && @tip.save
          @tip.generate_invoice_address!
          render :json => @tip.as_json(methods: [ :invoice_address_with_amount]) 
        else
          render :json => { error: @tip.errors.full_messages.join(" ") }
        end
      end
    end
  end

  def callback_for_blockchain
    @tip = Tip.find(params[:id])
    
    @tip.add_payment_details!({
      transaction_hash:       params[:transaction_hash],
      input_transaction_hash: params[:input_transaction_hash],
      input_address:          params[:input_address],
      value_in_satoshi:       params[:value].to_f,
      value_in_btc:           params[:value].to_f/100000000
      })
    
    render :nothing => true

  end

  def request_withdrawal
    if current_user.has_withdrawable_funds?
      UserMailer.request_withdrawal(current_user).deliver
    end
  end

end