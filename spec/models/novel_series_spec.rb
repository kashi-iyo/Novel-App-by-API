require 'rails_helper'

RSpec.describe NovelSeries, type: :model do

  it "複数の小説を持つこと" do
    series = FactoryBot.create(:novel_series, :has_novels)
    expect(series.novels.length).to eq 5
  end

  it "is タイトルが無ければ無効であること" do
    series = FactoryBot.build(:novel_series, series_title: nil)
    series.valid?
    expect(series.errors[:series_title]).to include("can't be blank")
  end
  it "is user_idがない場合無効であること" do
    series = FactoryBot.build(:novel_series, user_id: nil)
    series.valid?
    expect(series.errors[:user_id]).to include("can't be blank")
  end

  it "is タイトルが50文字を越えた場合無効であること" do
    series = FactoryBot.build(:novel_series, {series_title: "a" * 51})
    series.valid?
    expect(series.errors[:series_title]).to include("is too long (maximum is 50 characters)")
  end
  it "is あらすじが300文字を越えた場合無効であること" do
    series = FactoryBot.build(:novel_series, {series_description: "a" * 301})
    series.valid?
    expect(series.errors[:series_description]).to include("is too long (maximum is 300 characters)")
  end
  it "is あらすじが300文字を越えた場合無効であること" do
    series = FactoryBot.build(:novel_series, author: nil)
    series.valid?
    expect(series.errors[:author]).to include("can't be blank")
  end



end
