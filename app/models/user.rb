require 'open-uri'
require 'yajl'
include ERB::Util

class User < ActiveRecord::Base

  has_many :photos do 
    def today
      where(["entered_at>=? AND disqualified=false", Time.now.beginning_of_day])
    end

    def winners
      where(["winner=true AND disqualified=false"]).order("created_at DESC")
    end
  end

  has_many :received_tips, class_name: "Tip", foreign_key: "recipient_id"

  has_many :sent_tips, class_name: "Tip", foreign_key: "sender_id"
  
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable,
          :omniauthable, :omniauth_providers => [:facebook, :instagram]


  after_create :generate_tip_address!

  def self.find_by_username(username)
    where(username: username).first
  end

  def self.find_for_instagram_oauth(auth, signed_in_resource=nil)

    unless user = User.where(provider: auth.provider, uid: auth.uid).first
      user = User.new(provider: auth.provider, uid: auth.uid, password: Devise.friendly_token[0,20], email: "#{auth.uid}@instagram.com")
      user.save  
    end

    user.update_attributes( 
      access_token: auth.credentials.token, 
      username: auth.info.nickname, 
      full_name: auth.info.name, 
      avatar: auth.info.image, 
      bio: auth.info.bio, 
      website:auth.info.website )
    user
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      begin 
        dob = auth.extra.raw_info.birthday.split('/').map {|x| x.to_i}
        bday = DateTime.new(dob[2],dob[0],dob[1])
      rescue
        bday = ""
      end
      user = User.new(  first_name: auth.extra.raw_info.first_name, 
                        last_name:  auth.extra.raw_info.last_name, 
                        email:      auth.info.email,
                        birthday:   bday,
                        gender:     auth.extra.raw_info.gender,
                        provider:   auth.provider,
                        uid:        auth.uid,
                        password:   Devise.friendly_token[0,20]
                      )
      # user.remote_avatar_url = auth.info.image
      url = URI.parse(auth.info.image)
      h = Net::HTTP.new url.host, url.port
      h.use_ssl = url.scheme == 'https'

      head = h.start do |u|
        u.head url.path
      end
      # new_url = head['location']

      user.remote_avatar_url = head['location']
      user.skip_confirmation!
      user.save
    end
    user
  end

  def has_won_recently?
    photos.winners.any? && photos.winners.last.created_at >= App.winner_lockout.ago
  end

  def is_new?
    created_at > 10.seconds.ago
  end

  def ban!
    update_attributes(banned: true, banned_at: Time.now)
  end

  def unban!
    update_attributes(banned: false)
  end

  def provider_link
    "http://#{provider}.com/#{username}"
  end

  def generate_tip_address!(force=false)
    if tip_address.blank? || force==true
      callback_url = url_encode("http://#{App.url}/users/#{id}/callback_for_blockchain")
      if resp = Yajl::Parser.parse(open("https://blockchain.info/api/receive?method=create&address=#{App.wallet}&callback=#{callback_url}"))
        update_attributes(:tip_address => resp['input_address'])
      end
    end
    tip_address
  end

end
