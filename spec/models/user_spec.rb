require 'rails_helper'

RSpec.describe User, type: :model do

  it "is ニックネーム、アカウントID、メールアドレス、パスワード、確認用パスワードがあれば有効ある" do
    expect(FactoryBot.build(:user)).to be_valid
  end

  it "is ニックネームが無ければ無効である" do
    user = FactoryBot.build(:user, nickname: nil)
    user.valid?
    expect(user.errors[:nickname]).to include("can't be blank")
  end
  it "is アカウントとIDが無ければ無効である" do
    user = FactoryBot.build(:user, account_id: nil)
    user.valid?
    expect(user.errors[:account_id]).to include("can't be blank")
  end
  it "is メールアドレスが無ければ無効である" do
    user = FactoryBot.build(:user, email: nil)
    user.valid?
    expect(user.errors[:email]).to include("can't be blank")
  end
  it "is パスワードが無ければ無効である" do
    user = FactoryBot.build(:user, password: nil)
    user.valid?
    expect(user.errors[:password]).to include("can't be blank")
  end

  it "is ニックネームが30文字以上であれば無効である" do
    user = FactoryBot.build(:user, nickname: "a" * 31)
    user.valid?
    expect(user.errors[:nickname]).to include("is too long (maximum is 30 characters)")
  end
  it "is アカウントIDが15文字以上であれば無効である" do
    user = FactoryBot.build(:user, account_id: "a" * 16)
    user.valid?
    expect(user.errors[:account_id]).to include("is too long (maximum is 15 characters)")
  end
  it "is プロフィールが200文字以上であれば無効である" do
    user = FactoryBot.build(:user, profile: "a" * 201)
    user.valid?
    expect(user.errors[:profile]).to include("is too long (maximum is 200 characters)")
  end

  it "is ニックネームの重複は無効である" do
    FactoryBot.create(:user, nickname: "nickname")
    user = FactoryBot.build(:user, nickname: "nickname")
    user.valid?
    expect(user.errors[:nickname]).to include("has already been taken")
  end
  it "is アカウントIDの重複は無効である" do
    FactoryBot.create(:user, account_id: "account_id")
    user = FactoryBot.build(:user, account_id: "account_id")
    user.valid?
    expect(user.errors[:account_id]).to include("has already been taken")
  end
  it "is メールアドレスの重複は無効である" do
    FactoryBot.create(:user, email: "tester@example.com")
    user = FactoryBot.build(:user, email: "tester@example.com")
    user.valid?
    expect(user.errors[:email]).to include("has already been taken")
  end

  it "is パスワードと確認用パスワードが異なっていれば無効である" do
    user = FactoryBot.build(:user, password: "password", password_confirmation: "diffpassword")
    user.valid?
    expect(user.errors[:password_confirmation]).to include()
  end
end
