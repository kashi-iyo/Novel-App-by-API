FactoryBot.define do
  factory :user, aliases: [:owner] do
    sequence(:nickname) { |n| "User#{n}" }
    sequence(:account_id) { |n| "user_account#{n}" }
    sequence(:email) { |n| "User#{n}@example.com" }
    profile { "" }
    password { "123456" }
    password_confirmation { "123456" }
  end

  factory :updated_user, class: User do
    nickname { "updated_user" }
    profile { "updated_profile" }
    user_tag_name { "" }
  end

  factory :delete_user, class: User do
    nickname { "delete_user" }
    profile { "delete_profile" }
    user_tag_name { "" }
  end
end
