require 'rails_helper'

RSpec.describe 'Reviews API', type: :request do
  let(:user) {FactoryBot.create(:user)}
  let(:other_user) {FactoryBot.create(:user)}
  let(:game) {FactoryBot.create(:game)}
  let(:other_game) {FactoryBot.create(:game)}

  describe "#new" do
    context "サインインしている場合" do
      context "もともとレビューを投稿しているユーザーの場合" do
        context "そのゲームにレビューを投稿している場合" do
          it "edit画面へ遷移" do
            review_params = FactoryBot.attributes_for(:review, user:user, game:game)
            sign_in user
            post game_reviews_path(game), params: {review: review_params}
            get new_game_review_path(game)
            expect(response).to redirect_to edit_game_review_path(game, user.reviews.ids)
          end
        end
        context "違うゲームにレビューを投稿している場合" do
          it "成功" do
            review_params = FactoryBot.attributes_for(:review, user:user, game:game)
            sign_in user
            post game_reviews_path(game), params: {review: review_params}
            get new_game_review_path(other_game)
            expect(response).to be_successful
          end
        end
      end
      context "レビューを投稿していない場合" do
        it "成功" do
          sign_in user
          get new_game_review_path(game)
          expect(response).to be_successful
        end
      end
    end
    context "サインインしていない場合" do
      it "サインイン画面へ遷移" do
        get new_game_review_path(game)
        expect(response).to redirect_to "/users/sign_in"
      end
    end
  end
  describe "#create" do
    context "サインインしている場合" do
      context "適切な値の場合" do
        it "レビューを追加する" do
          review_params = FactoryBot.attributes_for(:review, user:user, game:game)
          sign_in user
          expect {
            post game_reviews_path(game), params: {review: review_params}
          }.to change(user.reviews, :count).by(1)
        end
        it "1ゲームにあたり、1ユーザーが2つ以上あってはいけない" do
          review_params = FactoryBot.attributes_for(:review, user: user, game: game)
          sign_in user
          post game_reviews_path(game), params: {review: review_params}
          other_review_params = FactoryBot.attributes_for(:review, user: user, game: game)
          expect {
            post game_reviews_url(game), params: {review: other_review_params}
          }.to_not change(user.reviews, :count)
        end
      end
      context "不適切な値の場合" do
        it "レビューを追加できない" do
          review_params = FactoryBot.attributes_for(:review, :invalid, user:user, game:game)
          sign_in user
          expect {
            post game_reviews_path(game), params: {review: review_params}
          }.to_not change(user.reviews, :count)
        end
      end
      context "タイトルがあり、レビュー内容がない場合" do
        it "レビューを追加できない" do
          review_params = FactoryBot.attributes_for(:review, user:user, game:game, body:nil)
          sign_in user
          expect {
            post game_reviews_path(game), params: {review: review_params}
          }.to_not change(user.reviews, :count)
        end
      end
      context "レビュー内容があり、タイトルがない場合" do
        it "レビューを追加できない" do
          review_params = FactoryBot.attributes_for(:review, user:user, game:game, title:nil)
          sign_in user
          expect {
            post game_reviews_path(game), params: {review: review_params}
          }.to_not change(user.reviews, :count)
        end
      end
    end
  end
  describe "#update" do
    context "サインインしている場合" do
      context "投稿したユーザーと同じ" do
        context "同じゲームの場合" do
          before do
            @review = FactoryBot.create(:review, user:user, game:game, body:"Old", score:8)
          end
          context "適切な値の場合" do
            it "レビューを更新できる" do
              sign_in user
              review_params = FactoryBot.attributes_for(:review, user:user, game:game, body:"New")
              patch game_review_path(game, id:@review.id), params: {review: review_params}
              expect(@review.reload.body).to eq review_params[:body]
            end
          end
          context "不適切な値の場合" do
            it "レビューを更新できない" do
              sign_in user
              review_params = FactoryBot.attributes_for(:review, :invalid, user:user, game:game, body:"New")
              patch game_review_path(game, id:@review.id), params: {review: review_params}
              expect(@review.reload.body).to eq "Old"
            end
          end
          context "タイトルがあり、レビュー内容がない場合" do
            it "レビューを更新できない" do
              sign_in user
              review_params = FactoryBot.attributes_for(:review, :invalid, user:user, game:game, body:nil, score:10)
              patch game_review_path(game, id:@review.id), params: {review: review_params}
              expect(@review.reload.score).to eq 8
            end
          end
          context "レビュー内容があり、タイトルがない場合" do
            it "レビューを更新できない" do
              sign_in user
              review_params = FactoryBot.attributes_for(:review, :invalid, user:user, game:game, title:nil, score:10)
              patch game_review_path(game, id:@review.id), params: {review: review_params}
              expect(@review.reload.score).to eq 8
            end
          end
        end
      end
      context "違うユーザーの場合" do
        before do
          @review = FactoryBot.create(:review, user:other_user, game:game, body: "Old")
        end
        it "レビューを更新できない" do
          sign_in user
          #controllerのreview_set対策
          other_review = FactoryBot.create(:review, user:user, game:game, body: "Sub")
          review_params = FactoryBot.attributes_for(:review, user:user, game:game, body: "New")
          patch game_review_path(game, id:@review.id), params: {review: review_params}
          expect(@review.reload.body).to eq "Old"
        end
      end
    end
  end
  describe "#destroy" do
    context "サインインしている場合" do
      context "同じユーザーの場合" do
        context "同じゲームの場合" do
          before do
            @review = FactoryBot.create(:review, user:user, game:game)
          end
          it "レビュー削除できる" do
            sign_in user
            expect{
              delete game_review_path(game, id:@review.id)
            }.to change(user.reviews, :count).by(-1)
          end
        end
      end
      context "違うユーザーの場合" do
        before do
          @review = FactoryBot.create(:review, user:other_user, game:game)
          other_review1 = FactoryBot.create(:review, user:user, game:game)
        end
        it "レビューを削除できない" do
          sign_in user
          expect{
            delete game_review_path(game, id:@review.id)
          }.to_not change(other_user.reviews, :count)
        end
      end
    end
  end
end