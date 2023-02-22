require 'rails_helper'

RSpec.describe "Reviews", type: :system do
  let(:user) {FactoryBot.create(:user)}
  let!(:game) {FactoryBot.create(:game, title:"test_game_title")}

  describe "create" do
    context "サインインしている場合" do
      it "レビュー投稿できる" do
        sign_in user
        visit root_path
        find('#test_game_title').click
        expect{
            click_link "レビュー投稿"
            create_review(title:"test_title")

            aggregate_failures do
                expect(page).to have_content "test_game_title"
                expect(page).to have_content "test_title"
            end
        }.to change(user.reviews, :count).by(1)
      end
    end
    context "サインインしていない場合" do
      context "レビュー投稿をしていない場合" do
        it "サインイン画面へ遷移し、レビュー作成画面へ" do
          visit root_path
          find('#test_game_title').click
          click_link "レビュー投稿"
          user_sign_in user
          expect{
            create_review(title: "test_title")

            aggregate_failures do
              expect(page).to have_content "test_game_title"
              expect(page).to have_content "test_title"
            end
          }.to change(user.reviews, :count).by(1)
        end
      end
      context "他のゲームには投稿している場合" do
        let(:other_game) {FactoryBot.create(:game)}
        let!(:other_game_review) {FactoryBot.create(:review,game:other_game,user:user)}
        it "サインイン画面へ遷移し、レビュー作成画面へ" do
          visit root_path
          find('#test_game_title').click
          expect{
            click_link "レビュー投稿"
            user_sign_in user
            create_review(title: "test_title")

            aggregate_failures do
              expect(page).to have_content "test_game_title"
              expect(page).to have_content "test_title"
            end
          }.to change(user.reviews, :count).by(1)
        end
      end
    end
  end
  describe "update" do
    context "サインインしている場合" do
      context "同じユーザーの場合" do
        context "ユーザーがそのゲームに対してレビューを書いていない場合" do
          context "他のゲームにも投稿していない場合" do
            it "レビュー編集ボタンが表示されない" do
              sign_in user
              visit root_path
              find('#test_game_title').click
              expect(page).to_not have_content "レビュー編集"
            end
          end
          context "他のゲームには投稿している" do
            let(:other_game) {FactoryBot.create(:game)}
            let!(:other_game_review) {FactoryBot.create(:review,game:other_game,user:user)}
            it "レビュー編集ボタンが表示されない" do
              sign_in user
              visit root_path
              find('#test_game_title').click
              expect(page).to_not have_content "レビュー編集"
            end
          end
        end
        context "ユーザーがそのゲームに対してレビューを書いている" do
          let!(:review) {FactoryBot.create(:review, game:game, user:user, title:"Old")}
          it "レビュー編集できる" do
            sign_in user
            visit root_path
            find('#test_game_title').click
            click_link "レビュー編集"
            edit_review(title:"New review")
            expect(page).to have_content "New review"
            expect(review.reload.title).to eq "New review"
          end
        end
      end
    end
    context "サインインしていない場合" do
      context "そのゲームに対してレビューを投稿している場合" do
        let!(:review) {FactoryBot.create(:review, game:game, user:user, title:"Old")}
        it "サインイン画面へ遷移し、レビュー編集できる" do
          visit root_path
          find('#test_game_title').click
          #expect(current_path).to eq "users/sign_in"
          click_link "レビュー投稿"
          user_sign_in user
          #expext(current_path).to eq edit_game_review_path(game:game, id:review.id)
          edit_review(title: "New review")
          expect(page).to have_content "New review"
          expect(review.reload.title).to eq "New review"
        end
      end
    end
  end
  describe "destroy" do
    context "サインインしている場合" do
      context "同じユーザーの場合" do
        context "ユーザーがそのゲームに対してレビューを書いていない場合" do
          context "他のゲームにも投稿していない場合" do
            it "レビュー削除ボタンが表示されない" do
              sign_in user
              visit root_path
              find('#test_game_title').click
              expect(page).to_not have_content "レビュー削除"
            end
          end
          context "他のゲームには投稿している" do
            let(:other_game) {FactoryBot.create(:game)}
            let!(:other_game_review) {FactoryBot.create(:review,game:other_game,user:user)}
            it "レビュー削除ボタンが表示されない" do
              sign_in user
              visit root_path
              find('#test_game_title').click
              expect(page).to_not have_content "レビュー削除"
            end
          end
        end
        context "ユーザーがそのゲームに対してレビューを書いている場合" do
          let!(:review) {FactoryBot.create(:review, user:user, game:game)}
          it "レビュー削除できる" do
            sign_in user
            visit root_path
            find('#test_game_title').click
            expect{
              click_link "レビュー削除"
              expect(page.accept_confirm).to eq "本当によろしいですか?"
              #confirmのaccept対策
              expect(page).to have_content "test_game_title"
            }.to change(user.reviews, :count).by(-1)
          end
        end
      end
    end
  end

  #deviseのsign_inメソッドを使わない時用
  def user_sign_in(user)
    fill_in "Eメール", with:user[:email]
    fill_in "パスワード", with:user.password
    click_button "ログイン"
  end

  #レビュー投稿する関数
  #キーワード引数
  def create_review(title:)
    fill_in "プレイ時間", with: 19.5
    fill_in "スコア", with: 9.0
    fill_in "タイトル", with: title
    click_button "送信"
  end

  #レビュー編集する関数
  #キーワード引数
  def edit_review(title:)
    fill_in "タイトル", with: title
    click_button "送信"
  end
end