require 'rails_helper'

RSpec.describe User, type: :model do
  it "email, password, nameがあれば有効であること" do
    user = User.new(
      email: "tester@exaple.com",
      password: "hahahah",
      name: "test_name"
    )
    user.valid?
    expect(user).to be_valid
  end

  it "emailがなければ無効な状態であること" do
    user = FactoryBot.build(:user, email: nil)
    user.valid?
    expect(user.errors[:email]).to include("を入力してください")
  end

  it "passwordがなければ、無効な状態であること" do
    user = FactoryBot.build(:user, password: nil)
    user.valid?
    expect(user.errors[:password]).to include("を入力してください")
  end

  it "nameがなければ、無効な状態であること" do
    user = FactoryBot.build(:user, name: nil)
    user.valid?
    expect(user.errors[:name]).to include("を入力してください")
  end
end