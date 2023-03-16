class LikesController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]
  before_action :review_params
  def create
    if @review.user_id != current_user.id
      Like.create(user_id: current_user.id, review_id: params[:id])
    else
      redirect_to game_path(@review.game)
    end
  end

  def destroy
    if Like.exists?(user_id: current_user.id, review_id: params[:id])
      Like.find_by(user_id: current_user.id, review_id: params[:id]).destroy
    else
      redirect_to game_path(@review.game)
    end
  end

  private
  def review_params
    @review = Review.find(params[:id])
  end
end
