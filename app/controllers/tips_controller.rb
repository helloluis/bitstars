class TipsController < ApplicationController

  def index
    @received_tips = current_user.received_tips
    @sent_tips = current_user.sent_tips
  end

  def create
    @tip = Tip.new(params[:tip].merge(sender_id: current_user.id).permit!)
    @tip.generate_invoice_address!
    respond_to do |format|
      format.json do 
        if @tip.valid? && @tip.save
          render :json => @tip.as_json(methods: [ :invoice_address_with_amount]) 
        else
          render :json => { error: @tip.errors.full_messages.join(" ") }
        end
      end
    end
  end

  def callback_for_blockchain
    @tip = Tip.find(params[:invoice_id])
    
    if @tip.pending?
      @tip.add_payment_details({
        transaction_hash:       params[:transaction_hash],
        input_transaction_hash: params[:input_transaction_hash],
        input_address:          params[:input_address],
        value_in_satoshi:       params[:value],
        value_in_btc:           params[:value]/100000000
        })
    end
  end

end