FactoryBot.define do
  factory :user_tag do
    sequence(:user_tag_name) { |n| "サンプルタグ#{n}" }
  end
end
