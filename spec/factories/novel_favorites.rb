FactoryBot.define do
  factory :novel_favorite do
    user
    novel
    favoriter { user.nickname }
  end
end
