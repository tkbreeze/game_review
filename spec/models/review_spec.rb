require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:user) {FactoryBot.create(:user)}
  let(:game) {FactoryBot.create(:game)}
  it "play_hour, score, user, gameがあれば有効であること" do
    review = Review.new(
      play_hour: 18.5,
      score: 9.0,
      user: user,
      game: game
    )
    review.valid?
    expect(review).to be_valid
  end

  it "play_hourがなければ無効な状態であること" do
    review = FactoryBot.build(:review, play_hour: nil)
    review.valid?
    expect(review.errors[:play_hour]).to include("を入力してください")
  end

  it "play_hourが0未満の時、無効な状態であること" do
    review = FactoryBot.build(:review, play_hour: -2)
    review.valid?
    expect(review.errors[:play_hour]).to match_array(/以上の値にしてください/)
  end

  it "play_hourが数値以外の時、無効な状態であること" do
    review = FactoryBot.build(:review, play_hour: "test")
    review.valid?
    expect(review.errors[:play_hour]).to include("は数値で入力してください")
  end

  it "scoreがなければ無効な状態であること" do
    review = FactoryBot.build(:review, score: nil)
    review.valid?
    expect(review.errors[:score]).to include("を入力してください")
  end

  it "scoreがマイナスの時、無効な状態であること" do
    review = FactoryBot.build(:review, score: -1.0)
    review.valid?
    expect(review.errors[:score]).to match_array(/範囲に含めてください/)
  end

  it "scoreが10より大きい時、無効な状態であること" do
    review = FactoryBot.build(:review, score: 11)
    review.valid?
    expect(review.errors[:score]).to match_array(/範囲に含めてください/)
  end

  it "scoreが数値以外の時、無効な状態であること" do
    review = FactoryBot.build(:review, score: "test")
    review.valid?
    expect(review.errors[:score]).to include("は数値で入力してください")
  end

  it "userがない時、無効な状態であること" do
    review = FactoryBot.build(:review, user: nil)
    review.valid?
    expect(review.errors[:user]).to include("を入力してください")
  end

  it "gameがない時、無効な状態であること" do
    review = FactoryBot.build(:review, game: nil)
    review.valid?
    expect(review.errors[:game]).to include("を入力してください")
  end

  it "1ユーザーあたり1ゲームにつき複数のレビューは認めない" do
    review = FactoryBot.create(:review, user: user, game: game)
    new_review = FactoryBot.build(:review, user: user, game: game)
    new_review.valid?
    expect(new_review.errors[:user_id]).to include("はすでに存在します")
  end
end