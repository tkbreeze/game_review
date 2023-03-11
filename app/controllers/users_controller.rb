class UsersController < ApplicationController
  #before_action :authenticate_user!
  def show
    #binding.pry
    if user_signed_in? and params[:user_id].blank?
      @user = current_user
      @flag = true
      @reviews = Review.where(user_id: @user).includes(:game).order(created_at: :desc)
    elsif params[:user_id].blank?
      redirect_to root_path
    else
      @user = User.find_by(id:params[:user_id])
      @flag = false
      @reviews = Review.where(user_id: @user).includes(:game).order(created_at: :desc)
    end
  end
end