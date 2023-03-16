require 'rails_helper'

RSpec.describe 'Likes API', type: :request do
  let(:user) {FactoryBot.create(:user)}
  let(:other_user) {FactoryBot.create(:user)}
  let(:game) {FactoryBot.create(:game)}
  let(:other_game) {FactoryBot.create(:game)}
  let!(:review) {FactoryBot.create(:review, user:other_user, game:game)}
  let!(:other_review) {FactoryBot.create(:review, user:user, game:game)}
  describe "#create" do
    context "サインインしている場合" do
      context "違う人のレビュにいいねをした場合" do
        context "まだいいねをそのレビューにしていない場合" do
          it "いいねができる" do
            #like_params = FactoryBot.attributes_for(:like, user:user, review:review)
            sign_in user
            expect{
              post create_like_path(review), xhr:true
            }.to change(user.reload.likes, :count).by(1)
          end
        end
        context "いいねをそのレビューにすでにしている場合" do
          let!(:like) {FactoryBot.create(:like, user:user, review:review)}
          it "いいねができない" do
            like_params = FactoryBot.attributes_for(:like, user:user, review:review)
            sign_in user
            expect{
              post create_like_path(review), params: {like: like_params}, xhr:true
            }.to_not change(user.reload.likes, :count)
          end
        end
      end
      context "自分のレビューにいいねをした場合" do
        it "いいねができない" do
          #like_params = FactoryBot.attributes_for(:like, user:user, review:other_review)
          sign_in user
          expect{
            post create_like_path(other_review), xhr:true
          }.to_not change(user.reload.likes,:count)
        end
      end
    end
    context "サインインしていない場合" do
      it "サインイン画面へ遷移" do
        like_params = FactoryBot.attributes_for(:like, user:user, review:review)
        post create_like_path(review), params: {like: like_params}, xhr:true
        expect(response.body()).to eq "ログインもしくはアカウント登録してください。"
      end
    end
  end
  describe "#destroy" do
    let!(:like) {FactoryBot.create(:like, user:user, review:review)}
    context "サインインしている場合" do
      context "いいねをしたレビューの場合" do
        it "いいねを消せる" do
          sign_in user
          expect{
            delete destroy_like_path(review), xhr:true
          }.to change(user.reload.likes,:count).by(-1)
        end
      end
      context "いいねをしていないレビューの場合" do
        let!(:other_review1) {FactoryBot.create(:review, game:game)}
        it "いいねができない" do
          sign_in user
          expect{
            delete destroy_like_path(other_review1), xhr:true
          }.to_not change(user.reload.likes,:count)
        end
      end
    end
    context "サインインしていない場合" do
      it "サインイン画面へ遷移" do
        delete destroy_like_path(review), xhr:true
        expect(response.body()).to eq "ログインもしくはアカウント登録してください。"
      end
    end
  end
end