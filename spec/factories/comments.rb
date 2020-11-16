FactoryBot.define do
  factory :comment do
    content { "コメントの内容が入ります。" }
    user
    novel
    commenter { user.nickname }
  end
end
