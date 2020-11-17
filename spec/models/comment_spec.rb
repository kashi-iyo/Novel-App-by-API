require 'rails_helper'

RSpec.describe Comment, type: :model do
  before do
    # 小説を所有するためのユーザー
    series_user = FactoryBot.create(:user)
    # コメントを残すための1件の小説を持つシリーズを作成
    @series = FactoryBot.create(:novel_series, :is_release, owner: series_user)
    # コメントを残すための1件の小説を作成
    @novel = FactoryBot.create(:novel, :is_release, novel_series: @series)
    # コメントを残すユーザーを作成
    @comment_user = FactoryBot.create(:user, nickname: "コメントマン")
  end
  it "全て揃っていれば有効であること" do
    expect(FactoryBot.build(:comment, user: @comment_user, novel: @novel)).to be_valid
  end
  it "contentが無ければ無効であること" do
    comment = FactoryBot.build(:comment, content: nil)
    comment.valid?
    expect(comment.errors[:content]).to include("can't be blank")
  end
  it "contentが200文字以上なら無効であること" do
    comment = FactoryBot.build(:comment, content: "a" * 201)
    comment.valid?
    expect(comment.errors[:content]).to include("is too long (maximum is 200 characters)")
  end
  it "user_idが無ければ無効であること" do
    comment = FactoryBot.build(:comment, user_id: nil)
    comment.valid?
    expect(comment.errors[:user]).to include("must exist")
  end
  it "novel_idが無ければ無効であること" do
    comment = FactoryBot.build(:comment, novel_id: nil)
    comment.valid?
    expect(comment.errors[:novel]).to include("must exist")
  end
  it "commenterが無ければ無効であること" do
    comment = FactoryBot.build(:comment, user: @comment_user, commenter: nil)
    comment.valid?
    expect(comment.errors[:commenter]).to include("can't be blank")
  end
end
