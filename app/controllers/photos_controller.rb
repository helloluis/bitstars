class PhotosController < ApplicationController

  before_filter :authenticate_user!, :except => [ :index, :show  ]

  before_filter :get_photo, :except => [ :index, :batch_create ]

  before_filter :get_rates, :only => [ :index, :show ]

  def index
    @photo = Photo.random(params[:view_count], params[:like_count], params[:today])
  end

  def show
    @photo.view!
    @next_photo = @photo.next_photo
  end

  def batch_create
    photos = []
    params[:photos].values.each do |p|
      photos << Photo.create( user:         current_user,
                    provider:     params[:provider], 
                    original_id:  p['id'],
                    description:  p['text'],
                    images: { 
                      standard:   p['standard'], 
                      low:        p['low'],
                      thumbnail:  p['thumbnail']
                      })
    end
    respond_to do |format|
      format.json { render :json => photos }
    end
  end

  def heart
    @photo.like!(current_user)
    respond_to do |format|
      format.json { render :json => { count: @photo.num_likes } }
    end
  end

  def unheart
    @photo.unlike!(current_user)
    respond_to do |format|
      format.json { render :json => { count: @photo.num_likes } }
    end
  end

  def winners
    @winning_photos = Photo.winners
  end

  def flag
    unless @photo.flagged_by?(current_user, params[:flag])
      current_user.flag(@photo, params[:flag])
      UserMailer.report_content(@photo, current_user)
      flash[:notice] = "Thank you for reporting this content, an administrator will review your request shortly."
    else
      flash[:alert] = "You've already flagged that content."
    end
    redirect_to :action => :show
  end

  def unflag!
    current_user.unflag!(@photo, params[:flag]) if @photo.flagged_by?(current_user, params[:flag])
    flash[:notice] = "We've removed your flag request on that item."
    redirect_to :action => :show
  end

  protected

    def get_photo
      @photo = Photo.where("disqualified=false AND id=?", params[:id]).first
    end

    def get_rates
      @rates = CurrencyExchangeRates.refresh!(false,true)
      @rates_updated = CurrencyExchangeRates.last.updated_at
    end
end