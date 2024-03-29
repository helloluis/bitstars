class User < ActiveRecord::Base

  include SocialNetworks

  extend FriendlyId
  friendly_id :username, use: [:slugged, :finders]

  has_many :photos do 
    def today
      where(["entered_at>=? AND disqualified=false", Time.now.in_time_zone.beginning_of_day]).order("entered_at DESC")
    end

    def winners
      where(["winner=true AND disqualified=false"]).order("entered_at DESC")
    end

    def qualified
      where(["disqualified=false"]).order("entered_at DESC")
    end

    def best
      where("disqualified=false").order("num_likes DESC").first
    end
  end

  has_many :likes 

  has_many :liked_photos, class_name: "Photo", through: :likes, source: :photo

  has_many :payouts

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
      user = User.new(provider: auth.provider, uid: auth.uid, password: Devise.friendly_token[0,20], email: "#{auth.uid}@instagram")
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
      email = auth.info.email ? auth.info.email : "#{auth.uid}@facebook"
      user = User.new(  access_token: auth.credentials.token,
                        first_name: auth.extra.raw_info.first_name, 
                        last_name:  auth.extra.raw_info.last_name, 
                        full_name:  auth.extra.raw_info.name,
                        username:   auth.extra.raw_info.name,
                        email:      email,
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

  def has_liked_photos?(photo_ids=[])
    return [] if photo_ids.nil? || photo_ids.empty?
    liked_photos = Like.select(:photo_id).where('user_id=? AND photo_id IN (?)', id, photo_ids.map(&:to_i))
    liked_photos.any? ? liked_photos.map(&:photo_id) : []
  end

  def is_admin?
    email && (App.emails.values.include?(email) || App.admin_emails.include?(email))
  end

  def has_completed_profile?
    !email.blank? && !phone.blank? && !address.blank? && !city.blank?
  end

  def has_won_recently?
    photos.winners.any? && photos.winners.last.entered_at >= App.winner_lockout.ago
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

  def calculate_total_earnings!(new_tip=0, new_winning=0)
    
    self.total_tips        = self.total_tips+(new_tip||0)
    self.total_winnings    = self.total_winnings+(new_winning||0)
    self.total_earnings    = self.total_earnings+(new_tip||0)+(new_winning||0)

    calculate_lifetime_earnings

    save
  end

  def calculate_lifetime_earnings
    tips                   = self.received_tips.map(&:final_amount_in_sats).sum
    prizes                 = self.prizes.confirmed.map(&:amount_in_sats).sum
    self.lifetime_tips     = tips
    self.lifetime_winnings = prizes
    self.lifetime_earnings = tips + prizes
  end

  def calculate_lifetime_earnings!
    calculate_lifetime_earnings
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

  def request_withdrawal!
    if requesting_withdrawal? 
      update_attributes(requesting_withdrawal: true, requested_withdrawal_on: Time.now)
      unless (requested_withdrawal_on && requested_withdrawal_on > 1.day.ago)
        UserMailer.request_withdrawal(self).deliver
      end
    else
      update_attributes(requesting_withdrawal: true, requested_withdrawal_on: Time.now)
      UserMailer.request_withdrawal(self).deliver
    end
  end

  def payout!
    
    if payout = payouts.create(
      amount_in_sats:     total_earnings,
      payout_to_charity:  payout_to_charity,
      charity:            charity,
      earnings_breakdown: {
        total_earnings:   total_earnings,
        total_winnings:   total_winnings,
        total_tips:       total_tips
        })

      update_attributes(requesting_withdrawal: false, 
                        requested_withdrawal_on: nil, 
                        total_earnings: 0.0, 
                        total_winnings: 0.0, 
                        total_tips: 0.0)
      return payout
      
    end
  end

end