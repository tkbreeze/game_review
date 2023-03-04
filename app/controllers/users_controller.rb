class UsersController < ApplicationController
  #before_action :authenticate_user!
  def show
    #binding.pry
    if params[:user_id].blank?
      redirect_to root_path
    elsif user_signed_in? and params[:user_id] == current_user.id.to_s
      @user = current_user
      @flag = true
      @reviews = Review.where(user_id: @user).includes(:game).order(created_at: :desc)
    else
      @user = User.find_by(id:params[:user_id])
      @flag = false
      @reviews = Review.where(user_id: @user).includes(:game).order(created_at: :desc)
    end
  end
end