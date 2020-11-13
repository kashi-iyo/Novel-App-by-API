require 'rails_helper'

RSpec.describe NovelSeries, type: :model do

  it "複数の小説を持つこと" do
    series = FactoryBot.create(:novel_series, :has_novels)
    expect(series.novels.length).to eq 5
  end

end
