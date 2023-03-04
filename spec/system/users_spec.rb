require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe "create" do
    context "正しい値の場合" do
      it "ユーザー登録できる" do
        visit root_path
        expect{
          click_link 'アカウント登録'
          fill_in "Eメール", with: "test@example.com"
          fill_in "パスワード", with: "testte"
          fill_in "パスワード（確認用）", with: "testte"
          fill_in "名前", with: "test_name"
          click_button "登録"
          aggregate_failures do
            expect(page).to have_content "Game Review"
          end
        }.to change(User, :count).by(1)
      end
    end
    context "正しい値でない時" do
      it "ユーザー登録できない" do
        visit root_path
        expect{
          click_link 'アカウント登録'
          fill_in "Eメール", with: "test@example.com"
          fill_in "パスワード", with: "testte"
          fill_in "パスワード（確認用）", with: "testte"
          fill_in "名前", with: nil
          click_button "登録"
          aggregate_failures do
            expect(page).to have_content "アカウント登録"
          end
        }.to_not change(User, :count)
      end
    end
  end
  describe "update" do
    let!(:user) {FactoryBot.create(:user, name:'Old', password:'test_password')}
    context "正しい値の場合" do
      it "編集できる" do
        sign_in user
        visit root_path
        expect{
          click_link user.email
          click_link 'アカウント設定'
          fill_in "Eメール", with: user.email
          fill_in "現在のパスワード", with: 'test_password'
          fill_in "名前", with: 'New'
          click_button "更新"
          aggregate_failures do
            expect(page).to_not have_content "アカウント編集"
          end
        }.to_not change(User, :count)
        expect(user.reload.name).to eq 'New'
      end
    end
    context "不適切な値の場合" do
      it "編集できない" do
        sign_in user
        visit root_path
        expect{
          click_link user.email
          click_link 'アカウント設定'
          fill_in "Eメール", with: user.email
          fill_in "現在のパスワード", with: 'test_password'
          fill_in "名前", with: nil
          click_button "更新"
          aggregate_failures do
            expect(page).to have_content "アカウント編集"
          end
        }.to_not change(User, :count)
        expect(user.reload.name).to eq 'Old'
      end
    end
  end
end