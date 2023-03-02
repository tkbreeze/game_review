class UsersController < ApplicationController
  before_action :authenticate_user!
  def show
    @user = current_user
    @reviews = Review.where(user_id: @user).includes(:game).order(created_at: :desc)
  end
end
