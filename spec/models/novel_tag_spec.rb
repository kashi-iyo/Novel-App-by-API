require 'rails_helper'

RSpec.describe NovelTag, type: :model do
  it "タグ名がnilなのは無効であること" do
    tags = FactoryBot.build(:novel_tag, novel_tag_name: nil)
    tags.valid?
    expect(tags.errors[:novel_tag_name]).to include("can't be blank")
  end
end
