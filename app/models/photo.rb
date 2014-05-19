class Photo < ActiveRecord::Base
  
  belongs_to :user
  has_many :tips
  has_many :likes
  before_create :check_eligibility

  serialize :images

  validate :check_already_entered, on: :create
  validate :check_max_submission, on: :create

  def self.winners
    where(["disqualified=false AND winner=true"]).order("created_at DESC")
  end

  def self.today
    where(["disqualified=false AND created_at>=?",Time.now.beginning_of_day]).
    order("num_likes DESC, num_views DESC")
  end

  def self.yesterday(limit=10)
    where(["disqualified=false AND created_at>=? AND created_at<?",Time.now.yesterday.beginning_of_day,Time.now.beginning_of_day]).
    order("num_likes DESC, num_views DESC").
    limit(limit)
  end

  def self.random(like_count=0, view_count=0, today=false)
    sql = ["disqualified=false"]
    sql[0] += " AND num_likes>=#{like_count.to_i}" if like_count && like_count.to_i>0
    sql[0] += " AND num_views>=#{view_count.to_i}" if view_count && view_count.to_i>0
    if today
      sql[0] += " AND created_at>=?"
      sql << Time.now.beginning_of_day
    end

    self.where(sql).order("RANDOM()").first
  end

  def position_today
    if num_likes > 0 && created_at>=Time.now.beginning_of_day
      if photos_today = Photo.where(["disqualified=false AND created_at>=?",Time.now.beginning_of_day]).order("num_likes DESC, num_views DESC").select(:id).limit(20)
        photo_ids = photos_today.map(&:id)
        hash = Hash[photo_ids.map.with_index.to_a]
        hash.keys.include?(id) ? (hash[id]+1) : false
      end
    end
  end

  def check_max_submission
    errors.add(:base, "You can only submit #{App.max_submissions_per_day} per day.") if user.photos.today.length >= App.max_submissions_per_day
  end

  def win!
    if user.has_won_recently?
      errors.add(:base, "This user has won already within the last #{App.winner_lockout} and can't be awarded again.") 
    else
      self.update_attributes(winner: true)
      user.update_attributes(last_won_on: Time.now, has_won: true)
      UserMailer.notify_winner(self).deliver
    end
  end

  def self.candidates_for_today
    self.where(["disqualified=false AND eligible=true AND created_at>=?", Time.now.beginning_of_day])
  end

  def check_eligibility
    self.eligible = !user.has_won_recently? && !nsfw
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
  end

  def self.already_entered?(user_id, provider, photo_id)
    where(["user_id=? AND provider=? AND original_id=? AND created_at>=?",user_id,provider,photo_id,Time.now.beginning_of_day]).exists?
  end

  def liked_by?(user)
    likes.where(user_id: user.id).exists?
  end

  def check_already_entered
    errors.add(:base, "You've already entered that selfie into today's competition.") if Photo.already_entered?(user, user.provider, original_id)
  end

  def next_photo
    self.class.unscoped.where("disqualified=false AND id>?", id).order("created_at ASC").first
  end

  def prev_photo
    self.class.unscoped.where("disqualified=false AND id<?", id).order("created_at ASC").first
  end

end