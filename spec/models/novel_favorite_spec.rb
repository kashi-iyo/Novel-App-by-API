require 'rails_helper'

RSpec.describe NovelFavorite, type: :model do
  before do
    # 小説を所有するためのユーザー
    series_user = FactoryBot.create(:user)
    # コメントを残すための1件の小説を持つシリーズを作成
    @series = FactoryBot.create(:novel_series, :is_release, owner: series_user)
    # コメントを残すための1件の小説を作成
    @novel = FactoryBot.create(:novel, :is_release, novel_series: @series)
    # コメントを残すユーザーを作成
    @favorites_user = FactoryBot.create(:user, nickname: "フェイバリットマン")
  end
  it "全て揃っていれば有効であること" do
    expect(FactoryBot.build(
      :novel_favorite, user: @favorites_user, novel: @novel)
    ).to be_valid
  end
  it "user_idが無ければ無効であること" do
    novel_favorite = FactoryBot.build(:novel_favorite, user_id: nil)
    novel_favorite.valid?
    expect(novel_favorite.errors[:user_id]).to include("can't be blank")
  end
  it "novel_idが無ければ無効であること" do
    novel_favorite = FactoryBot.build(:novel_favorite, novel_id: nil)
    novel_favorite.valid?
    expect(novel_favorite.errors[:novel_id]).to include("can't be blank")
  end
  it "favoriterが無ければ無効であること" do
    novel_favorite = FactoryBot.build(:novel_favorite, favoriter: nil)
    novel_favorite.valid?
    expect(novel_favorite.errors[:favoriter]).to include("can't be blank")
  end
end
