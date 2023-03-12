class LikesController < ApplicationController
  before_action :post_params
  before_action :authenticate_user!
  def create
    Like.create(user_id: current_user.id, post_id: params[:id])
  end

  def destroy
    Like.find_by(user_id: current_user.id, post_id: params[:id]).destroy
  end

  private
  def review_params
    @review = Review.find(params[:id])
  end
end
