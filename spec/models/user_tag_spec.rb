require 'rails_helper'

RSpec.describe UserTag, type: :model do
  it "タグ名がnilなのは無効であること" do
    tags = FactoryBot.build(:user_tag, user_tag_name: nil)
    tags.valid?
    expect(tags.errors[:user_tag_name]).to include("can't be blank")
  end
end
