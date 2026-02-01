# spec/factories/teams.rb
FactoryBot.define do
  factory :team do
    sequence(:display_name) { |n| "Team #{n}" }
    status { :active }
  end
end
