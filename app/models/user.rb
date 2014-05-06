class User < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader
  
  devise :database_authenticatable, :registerable, :confirmable,
          :recoverable, :rememberable, :trackable, :validatable,
          :omniauthable, :omniauth_providers => [:facebook]

  #after_create :create_in_mailchimp

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
                        last_name: auth.extra.raw_info.last_name, 
                        email: auth.info.email,
                        birthday: bday,
                        gender: auth.extra.raw_info.gender,
                        provider: auth.provider,
                        uid: auth.uid,
                        password: Devise.friendly_token[0,20]
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

  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth[:provider], :uid => auth[:uid].to_s).first
    unless user
      user = User.create(:first_name => auth[:first_name], 
                         :last_name => auth[:last_name],
                         :provider => auth[:provider], 
                         :uid => auth[:uid], 
                         :password => Devise.friendly_token[0,20],
                         :remote_avatar_url => auth[:remote_avatar_url]
                        )
    end
    user
  end

  def self.build_twitter_auth_cookie_hash(auth)
    fullname = auth.extra.raw_info.name.split(' ')
    {
      :provider => auth.provider, :uid => auth.uid.to_i,
      :access_token => auth.credentials.token, :access_secret => auth.credentials.secret,
      :first_name => fullname[0], :last_name => fullname[1],
      :remote_avatar_url => auth.info.image,
    }
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
    if user
      return user
    else
      registered_user = User.where(:email => access_token.info.email).first
      if registered_user
        return registered_user
      else
        user = User.new(  first_name: data.first_name,
                          last_name: data.last_name,
                          provider: access_token.provider,
                          email: data.email,
                          uid: access_token.uid ,
                          password: Devise.friendly_token[0,20],
                        )
        user.remote_avatar_url = data.image
        user.skip_confirmation!
        user.save
      end
    end
    user
  end

  def full_name
    name || [first_name,last_name].join(" ")
  end

  def name_and_location
    [friendly_first_name, city].join(", ")
  end

  def friendly_first_name
    first_name || (name ? name.split(" ").first : email.split('@').first)
  end

  def summary
    { email: email, first_name: first_name, last_name: last_name, gender: gender, is_new: is_new? }
  end

  def is_new?
    created_at > 10.seconds.ago
  end

  def address1
    self.latest_order.address1
  end

  def address2
    self.latest_order.address2
  end

  def city
    self.latest_order.city
  end

  def state
    self.latest_order.state
  end

  def country
    self.latest_order.country
  end

end
