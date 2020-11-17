module NovelTagSpecsHelpers

    def return_one_tag_and_multiple_series
        # 1件のタグを作成
        @tag = FactoryBot.create(:novel_tag)
        # 5件のシリーズを作成
        @series = FactoryBot.create_list(:novel_series, 5, :is_release)
        # 5件のシリーズそれぞれに定義したタグとの関連付けを行う
        @series.map do |series|
            FactoryBot.create(:novel_tag_map, novel_series: series, novel_tag: @tag)
        end
    end

    # シリーズにお気に入りやコメントなどのデータを追加する
    # count => 作成したいシリーズの数を入力
    # type => commentsかfavoritesかを指定
    def return_series_having_items
        # 1件のシリーズを作成
        @new_series = FactoryBot.create(:novel_series, :is_release)
        # シリーズにタグを登録する
        FactoryBot.create(:novel_tag_map, novel_series: @new_series, novel_tag: @tag)
        # 小説を作成し、定義したシリーズと紐付け
        novel = FactoryBot.create(:novel, novel_series: @new_series)
        # データの追加を行うユーザーを作成
        user = FactoryBot.create(:user)
        # 1件の小説にお気に入りを生成
        FactoryBot.create(:novel_favorite, user: user, novel: novel)
        # 1件の小説にコメントを生成
        FactoryBot.create(:comment, user: user, novel: novel)
    end

end