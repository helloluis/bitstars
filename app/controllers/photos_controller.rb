class PhotosController < ApplicationController

  include ApplicationHelper

  before_filter :get_photo, :except => [ :index, :by_date, :batch_create, :not_found, :winners, :hearts ]

  before_filter :authenticate_user!, :except => [ :index, :show, :by_date, :not_found, :winners  ]

  before_filter :authenticate_admin!, :only => [ :set_winner, :unset_winner, :disqualify, :requalify ]

  before_filter :get_rates, :only => [ :index, :show, :by_date ]

  def index
    @random = true
    @photo = Photo.random(params[:view_count], params[:like_count], params[:today])
    @date = @photo.created_at if @photo
  end

  def show
    @photo.view!
    @date = @photo.created_at
    @next_photo = @photo.next_photo
  end

  def batch_create
    photos = []
    photo_errors = []
    params[:photos].values.each do |p|
      photo = Photo.new( user:         current_user,
                    provider:     params[:provider], 
                    original_id:  p['id'],
                    description:  p['text'],
                    images: { 
                      standard:   p['standard'], 
                      low:        p['low'],
                      thumbnail:  p['thumbnail']
                      },
                    eligible: current_user.has_won_recently? )
      if photo.valid? && photo.save
        photos << photo 
      else
        logger.info photo.errors.inspect
        photo_errors << photo.errors
      end
    end
    respond_to do |format|
      format.json { render :json => { photos: photos, errors: photo_errors } }
    end
  end

  def hearts
    @hearted_photos = current_user.has_liked_photos?(params[:photo_ids])
    respond_to do |format|
      format.json { render :json => { ids: @hearted_photos } }
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

  def by_date
    @date        = Date.parse("#{params[:year]}-#{params[:month]}-#{params[:day]}")
    @date_after  = @date+1.day
    @date_before = @date-1.day
    @photos      = Photo.by_date(@date).page(params[:page]).per(30)
  end

  def set_winner
    @photo.win!
    return redirect_to photo_path(@photo)
  end

  def unset_winner
    @photo.unwin!
    return redirect_to photo_path(@photo)
  end

  def disqualify
    @photo.disqualify!
    return redirect_to photo_path(@photo)
  end

  def requalify
    @photo.requalify!
    return redirect_to photo_path(@photo)
  end

  protected

    def get_photo
      if user_is_admin?
        unless (@photo = Photo.find(params[:id]))
          redirect_to not_found_photos_path
        end
      else
        unless (@photo = Photo.where("disqualified=false AND id=?", params[:id]).first)
          redirect_to not_found_photos_path
        end
      end
    end

    def get_rates
      @rates = CurrencyExchangeRates.refresh!(false,true)
      @rates_updated = CurrencyExchangeRates.last.updated_at
    end

    def authenticate_admin!
      if user_signed_in?
        unless current_user.is_admin?
          flash[:alert] = "You are not an administrator."
          return redirect_to photo_path(@photo)
        end
      else
        return redirect_to photo_path(@photo)
      end
    end

end