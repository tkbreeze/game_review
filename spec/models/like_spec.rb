require 'rails_helper'

RSpec.describe Like, type: :model do
  let(:user) {FactoryBot.create(:user)}
  let(:game) { FactoryBot.create(:game)}
  let(:review) {FactoryBot.create(:review,user:user, game:game)}
  it "userとreviewがあれば、有効な状態であること" do
    like = Like.new(
      user: user,
      review: review
    )
    like.valid?
    expect(like).to be_valid
  end
  it "userがなければ、有効な状態でないこと" do
    like = FactoryBot.build(:like, user:nil)
    like.valid?
    expect(like).to be_valid
  end
  it "gameがなければ、有効な状態でないこと" do
    like = FactoryBot.build(:like, review:nil)
    like.valid?
    expect(like).to be_valid
  end
  it "userとgameにつき2つ以上のいいねはつかない" do
    like = FactoryBot.create(:like,user:user,review:review)
    new_like = FactoryBot.build(:like,user:user,review:review)
    new_like.valid?
    expect(new_like.errors[:user_id]).to include("はすでに存在します")
  end
end
