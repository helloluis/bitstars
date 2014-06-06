namespace :db do
  desc "Initialize User Counter Fields (don't run this more than once per environment)"
  task :initialize_user_counters => :environment do
    Like.all.each do |like|
      like.photo.user.increment!(:num_likes) rescue nil
    end
    User.all.each do |user|
      user.update_attributes(num_photos: user.photos.qualified.count) rescue nil
    end
    Tip.all.each do |tip|
      tip.recipient.increment!(:num_tips) rescue nil
    end
    Photo.all.each do |photo|
      photo.user.increment!(:num_views, photo.num_views) rescue nil
    end
  end
end