FactoryBot.define do

  factory :novel do
    novel_title { "タイトル" }
    novel_description { "あらすじ" }
    novel_content { "内容" }
    author { "田中" }
    release { false }
    novel_series  # novel_seriesにアソシエーション
    user { novel_series.owner } # userにアソシエーション

    trait :is_release do
      release { true }
    end

  end


end
