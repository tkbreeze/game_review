require 'rails_helper'

RSpec.describe "Likes", type: :system do
  let(:user) {FactoryBot.create(:user)}
  let(:other_user) {FactoryBot.create(:user)}
  let!(:game) {FactoryBot.create(:game, title:"test_game_title")}
  let!(:review) {FactoryBot.create(:review, user:other_user, game:game)}
  describe "create" do
    context "正しい場合" do
      it "いいねできる" do
        sign_in user
        visit root_path
        find('#test_game_title').click
        expect{
          find('.like-link').click
        }.to change(user.likes, :count).by(1)
      end
      it "いいね消去は表示されない" do
        sign_in user
        visit root_path
        find('#test_game_title').click
        expect(page).to have_no_css '.dis-like-link'
      end
    end
  end
  describe "destroy" do
    let!(:like) {FactoryBot.create(:like, user:user, review:review)}
    context "いいねをしている場合" do
      it "いいねを取り消せる" do
        sign_in user
        visit root_path
        find('#test_game_title').click
        expect{
          find('.dis-like-link').click
        }.to change(user.likes, :count).by(-1)
      end
      it "いいねは表示されない" do
        sign_in user
        visit root_path
        find('#test_game_title').click
        expect(page).to have_no_css '.like-link'
      end
    end
  end
end