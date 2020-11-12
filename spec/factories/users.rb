FactoryBot.define do
  factory :user do
    sequence(:nickname) { |n| "User#{n}" }
    sequence(:account_id) { |n| "user_account#{n}" }
    sequence(:email) { |n| "User#{n}@example.com" }
    password { "123456" }
    password_confirmation { "123456" }
  end
end
