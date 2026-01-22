# frozen_string_literal: true

FactoryBot.define do
  factory :subreddit do
    association :bot
    sequence(:name) { |n| "subreddit#{n}" }
    options { {} }
  end
end
