FactoryBot.define do

  factory :novel do
    novel_title { "タイトル" }
    novel_description { "あらすじ" }
    novel_content { "内容" }
    release { false }
    novel_series  # novel_seriesにアソシエーション
    user { novel_series.owner } # userにアソシエーション
    author { user }

    trait :is_release do
      release { true }
    end

  end


end
