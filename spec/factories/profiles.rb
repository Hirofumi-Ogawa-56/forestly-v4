# spec/factories/profiles.rb
FactoryBot.define do
  factory :profile do
    association :user
    name { Faker::Name.name }
    label { "メイン" }
    status { :active }
    team_role { :member }
  end
end
