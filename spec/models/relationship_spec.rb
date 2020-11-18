require 'rails_helper'

RSpec.describe Relationship, type: :model do
  it "is user_idがない場合無効であること" do
    relationship = FactoryBot.build(:relationship, user: nil)
    relationship.valid?
    expect(relationship.errors[:user_id]).to include("can't be blank")
  end
  it "is follow_idがない場合無効であること" do
    relationship = FactoryBot.build(:relationship, follow: nil)
    relationship.valid?
    expect(relationship.errors[:follow_id]).to include("can't be blank")
  end
end
