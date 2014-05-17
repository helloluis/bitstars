class PhotosController < ApplicationController

  before_filter :authenticate_user!, :except => [ :index, :show  ]

  before_filter :get_photo, :except => [ :index, :batch_create ]

  def index
    @photo = Photo.random
  end

  def show
    @photo.view!
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

  protected

    def get_photo
      @photo = Photo.where("disqualified=false AND id=?", params[:id]).first
    end
end