FactoryGirl.define do
  sequence :photo_filename do |n|
    "photo#{n}.jpg"
  end

  factory :photo do 
    user
    provider 'instagram'
    entered_at { Time.now }
    disqualified false
  end

  sequence :user_email do |n|
    "user#{n}@email.com"
  end

  factory :user do 
    email   { generate(:user_email) }
    password "password"
  end
end