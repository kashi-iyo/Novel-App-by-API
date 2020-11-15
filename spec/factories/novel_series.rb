FactoryBot.define do

  factory :novel_series do
    series_title { "タイトル" }
    series_description { "あらすじ" }
    release { false }
    owner
    author { owner.nickname }

    # 公開されているシリーズ
    trait :is_release do
        release { true }
    end

    trait :has_novels do
      after(:create) { |series| create_list(:novel, 5, novel_series: series) }
    end
  end

  factory :updated_series, class: NovelSeries do
    series_title { "更新用シリーズタイトル" }
    release { true }
    owner
    author { owner.nickname }
  end

  factory :delete_series, class: NovelSeries do
    series_title { "削除用シリーズタイトル" }
    release { true }
    owner
    author { owner.nickname }
  end

end
