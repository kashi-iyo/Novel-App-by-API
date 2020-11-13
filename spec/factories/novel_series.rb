FactoryBot.define do

  factory :novel_series do
    series_title { "タイトル" }
    series_description { "あらすじ" }
    release { false }
    author { "田中" }
    owner

    # 公開されているシリーズ
    trait :is_release do
        release { true }
    end

    trait :has_novels do
      after(:create) { |series| create_list(:novel, 5, novel_series: series) }
    end
  end

end
