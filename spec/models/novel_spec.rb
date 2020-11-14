require 'rails_helper'

RSpec.describe Novel, type: :model do

  it "is タイトルが無ければ無効であること" do
    novel = FactoryBot.build(:novel, novel_title: nil)
    novel.valid?
    expect(novel.errors[:novel_title]).to include("can't be blank")
  end
  it "is 本文が無ければ無効であること" do
    novel = FactoryBot.build(:novel, novel_content: nil)
    novel.valid?
    expect(novel.errors[:novel_content]).to include("can't be blank")
  end
  it "is authorが無ければであれば無効であること" do
    novel = FactoryBot.build(:novel, author: nil)
    novel.valid?
    expect(novel.errors[:author]).to include("can't be blank")
  end
  it "is user_idが無ければであれば無効であること" do
    novel = FactoryBot.build(:novel, user_id: nil)
    novel.valid?
    expect(novel.errors[:user_id]).to include("can't be blank")
  end
  it "is novel_series_idが無ければであれば無効であること" do
    novel = FactoryBot.build(:novel, novel_series_id: nil)
    novel.valid?
    expect(novel.errors[:novel_series_id]).to include("can't be blank")
  end

  it "is タイトルが50文字以上であれば無効であること" do
    novel = FactoryBot.build(:novel, novel_title: "a" * 51)
    novel.valid?
    expect(novel.errors[:novel_title]).to include("is too long (maximum is 50 characters)")
  end

  it "is 前書きが300文字以上であれば無効であること" do
    novel = FactoryBot.build(:novel, novel_description: "a" * 301)
    novel.valid?
    expect(novel.errors[:novel_description]).to include("is too long (maximum is 300 characters)")
  end


end
