include ApplicationHelper
class Photo < ActiveRecord::Base
  
  belongs_to :user
  has_many :tips
  has_many :likes
  has_many :likers, class_name: "User", through: :likes, source: :user
  has_one :prize

  make_flaggable :not_selfie, :nsfw, :fake

  serialize :images

  validate :check_already_entered, on: :create
  validate :check_max_submission, on: :create

  after_create :increment_user_count
  after_create :notify_admin

  def self.winners
    where(["disqualified!=true AND winner=true"]).order("entered_at DESC")
  end

  def self.todays_winner
    where(["disqualified!=true AND winner=true AND entered_at>=?",Time.now.in_time_zone.beginning_of_day])
  end

  def self.today
    where(["disqualified!=true AND entered_at>=?",Time.now.in_time_zone.beginning_of_day]).
    order("num_likes DESC, num_views DESC")
  end

  def self.yesterday(limit=10)
    time = Time.now.in_time_zone
    where(["disqualified!=true AND entered_at>=? AND entered_at<?",time.yesterday.beginning_of_day,time.beginning_of_day]).
    order("num_likes DESC, num_views DESC").
    limit(limit)
  end

  def self.by_date(date)
    where(["disqualified!=true AND entered_at>=? AND entered_at<?",date.in_time_zone,date.in_time_zone+1.day]).
    order("num_likes DESC, num_views DESC")
  end

  def self.winner_by_date(date)
    where(["disqualified!=true AND entered_at>=? AND entered_at<? AND winner=true",date.in_time_zone,date.in_time_zone+1.day]).first
  end

  def self.random(not_id=nil, like_count=0, view_count=0, today=false)
    sql = ["disqualified!=true"]
    sql[0] += " AND id!=#{not_id}" if not_id
    sql[0] += " AND num_likes>=#{like_count.to_i}" if like_count && like_count.to_i>0
    sql[0] += " AND num_views>=#{view_count.to_i}" if view_count && view_count.to_i>0
    if today
      sql[0] += " AND entered_at>=?"
      sql << Time.now.beginning_of_day
    end

    self.where(sql).order("RANDOM()").first
  end

  def created_date
    entered_at.strftime("%Y-%m-%d")
  end

  def position_today
    time = Time.now.in_time_zone
    if num_likes > 0 && entered_at>=time.beginning_of_day
      if photos_today = Photo.where(["disqualified!=true AND entered_at>=?",time.beginning_of_day]).order("num_likes DESC, num_views DESC").select(:id).limit(20)
        photo_ids = photos_today.map(&:id)
        hash = Hash[photo_ids.map.with_index.to_a]
        hash.keys.include?(id) ? (hash[id]+1) : false
      end
    end
  end

  def check_max_submission
    errors.add(:base, "You can only submit #{App.max_submissions_per_day} per day.") if user.photos.today.length >= App.max_submissions_per_day
  end

  def win!(override_prize=nil)
    prize = override_prize ? override_prize : php_to_satoshis(Prize.daily_prize_amount(created_date))
    
    if winner?
      
      errors.add(:base, "This photo has already won.")

    elsif user.has_won_recently?
      
      errors.add(:base, "This user has won already within the last #{App.winner_lockout/86400} days and can't be awarded again.") 

    elsif Photo.where("winner=true AND entered_at>=? AND entered_at<?", entered_at.beginning_of_day, entered_at+1.day).exists?

      errors.add(:base, "A winner has already been selected for #{created_date}.")

    else
      
      self.update_attributes(winner: true)
      self.create_prize(user: user, amount_in_sats: prize)
      user.update_attributes(last_won_on: Time.now, has_won: true)
      
    end
  end

  def unwin!
    self.update_attributes(winner: false)
    self.prize.revoke! if self.prize
  end

  def disqualify!
    self.update_attributes(disqualified: true, winner: false)
    self.user.decrement!(:num_photos)
  end

  def requalify!
    self.update_attributes(disqualified: false)
    self.user.increment!(:num_photos)
  end

  def nsfw=(boolean)
    attributes[:eligible] = false if boolean
    attributes[:nsfw] = boolean
  end

  def tip!(sender, amount_in_btc, amount_in_php)
    Tip.send!(sender, self, amount_in_btc, amount_in_php)
  end

  def like!(user)
    Like.like!(self, user)
  end

  def unlike!(user)
    Like.unlike!(self, user)
  end

  def view!
    increment!(:num_views)
    user.increment!(:num_views)
  end

  def self.already_entered?(user_id, provider, photo_id)
    where(["user_id=? AND provider=? AND original_id=? AND entered_at>=?",user_id,provider,photo_id,Time.now.in_time_zone.beginning_of_day]).exists?
  end

  def liked_by?(user)
    likes.where(user_id: user.id).exists?
  end

  def check_already_entered
    errors.add(:base, "You've already entered that selfie into today's competition.") if Photo.already_entered?(user, user.provider, original_id)
  end

  def next_photo
    self.class.unscoped.where("disqualified!=true AND id>?", id).order("entered_at ASC").first
  end

  def prev_photo
    self.class.unscoped.where("disqualified!=true AND id<?", id).order("entered_at ASC").first
  end

  def increment_user_count
    user.increment!(:num_photos)
  end

  def notify_admin
    UserMailer.notify_admin(self).deliver
  end

end