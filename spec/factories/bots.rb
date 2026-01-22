# frozen_string_literal: true

FactoryBot.define do
  factory :bot do
    sequence(:name) { |n| "bot_#{n}" }
  end
end
