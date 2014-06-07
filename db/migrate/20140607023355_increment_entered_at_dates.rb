class IncrementEnteredAtDates < ActiveRecord::Migration
  def change
    Photo.all.each do |photo|
      photo.update_attributes(entered_at: photo.created_at)
    end
  end
end
