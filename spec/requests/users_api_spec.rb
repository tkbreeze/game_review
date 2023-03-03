require 'rails_helper'

RSpec.describe "Users API", type: :request do

  describe "GET /show" do
    context "サインインしている場合" do
      let(:user) {FactoryBot.create(:user)}
      it "成功" do
        sign_in user
        get "/users/show"
        expect(response).to have_http_status(:success)
      end
    end
    context "サインインしていない場合" do
      it "失敗" do
        get "/users/show"
        expect(response).to_not be_success
      end
    end
  end

  describe "#create" do
    context "正しい値の場合" do
      it "ユーザー追加" do
        user_params = FactoryBot.attributes_for(:user)
        expect do
          post user_registration_path, params: {user: user_params}
        end.to change(User, :count).by(1)
      end
      it "正しい名前でユーザー登録" do
        user_params = FactoryBot.attributes_for(:user, name:"test_name")
        post "/users", params: {user: user_params}
        expect(User.where(id: 1).select[:name]).to eq "test_name"
      end
    end
    context "nameがない場合" do
      it "ユーザー追加できない" do
        user_params = FactoryBot.attributes_for(:user,name:nil)
        expect{
          post "/users", params: {user: user_params}
        }.to_not change(User, :count)
      end
    end
  end

  describe "#update" do
    let(:user) {FactoryBot.create(:user, name: "Old")}
    context "正しい値の場合" do
      it "編集できる" do
        user_params = FactoryBot.attributes_for(:user, name:"New")
        patch user_registration_path, params: {user:user_params}
        expect(User.where(id:1).select[:name]).to eq "New"
      end
    end
    context "不適切な値の集合" do
      it "編集できない" do
        user_params = FactoryBot.attributes_for(:user, name:nil)
        patch user_registration_path, params: {user:user_params}
        expect(User.where(id:1).select[:name]).to eq "Old"
      end
    end
  end
end
