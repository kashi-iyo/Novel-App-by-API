FactoryBot.define do
  factory :novel_tag do
    sequence(:novel_tag_name) { |n| "サンプルタグ#{n}" }
  end
end
