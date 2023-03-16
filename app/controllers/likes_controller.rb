class LikesController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]
  before_action :review_params
  def create
    Like.create(user_id: current_user.id, review_id: params[:id])
  end

  def destroy
    Like.find_by(user_id: current_user.id, review_id: params[:id]).destroy
  end

  private
  def review_params
    @review = Review.find(params[:id])
  end
end
