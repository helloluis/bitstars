require 'open-uri'
require 'yajl'
include ERB::Util

class User < ActiveRecord::Base

  include SocialNetworks

  extend FriendlyId
  friendly_id :username, use: [:slugged, :finders]

  has_many :photos do 
    def today
      where(["entered_at>=? AND disqualified=false", Time.now.in_time_zone.beginning_of_day])
    end

    def winners
      where(["winner=true AND disqualified=false"]).order("created_at DESC")
    end

    def qualified
      where(["disqualified=false"])
    end
  end

  has_many :prizes do 
    def confirmed
      where("revoked!=true")
    end

    def revoked
      where("revoked=true")
    end
  end

  has_many :received_tips, class_name: "TipPayment", foreign_key: "recipient_id"
  
  has_many :sent_tips, class_name: "TipPayment", foreign_key: "sender_id"
  
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable,
          :omniauthable, :omniauth_providers => [:facebook, :instagram]

  validates_uniqueness_of :email

  make_flagger
  
  after_initialize :init_default_values

  def init_default_values
    self.country = "Philippines"
  end

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
      username:     auth.info.nickname, 
      full_name:    auth.info.name, 
      avatar:       auth.info.image, 
      bio:          auth.info.bio, 
      website:      auth.info.website )
    user
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user

      user = User.new(  access_token: auth.credentials.token,
                        first_name: auth.extra.raw_info.first_name, 
                        last_name:  auth.extra.raw_info.last_name, 
                        full_name:  auth.extra.raw_info.name,
                        username:   auth.extra.raw_info.name,
                        email:      auth.info.email,
                        gender:     auth.extra.raw_info.gender,
                        provider:   auth.provider,
                        uid:        auth.uid,
                        password:   Devise.friendly_token[0,20]
                      )

      user.avatar = auth.info.image
      user.save
    end
    user
  end

  def is_admin?
    email && (App.emails.values.include?(email) || App.admin_emails.include?(email))
  end

  def has_completed_profile?
    !email.blank? && !phone.blank? && !address.blank? && !city.blank?
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
    provider=='facebook' ?
    "http://#{provider}.com/profile.php?id=#{uid}" :
    "http://#{provider}.com/#{username}"
  end

  def has_withdrawable_funds?
    total_earnings > App.minimum_withdrawal
  end

  def calculate_total_earnings!
    tips                = self.received_tips.map(&:final_amount_in_sats).sum
    prizes              = self.prizes.confirmed.map(&:amount_in_sats).sum
    self.total_tips     = tips
    self.total_winnings = prizes
    self.total_earnings = tips + prizes
    save
  end

  def calculate_total_tips_sent!
    tips = self.sent_tips.map(&:final_amount_in_sats).sum
    self.total_tips_sent = tips
    save
  end

  def total_earnings_in_mbtc
    total_earnings/10000
  end

  def location
    [ city, country ].reject{|r|r.blank?}.join(", ")
  end

end