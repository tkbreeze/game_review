class ReviewsController < ApplicationController
    before_action :authenticate_user!, only: :new
    before_action :review_set, only: [:show,:destroy, :edit, :update]
    before_action :game_set, only: [:new,:show, :edit]

    def new
        @review = Review.new
        #@review.build
    end
    
    def create
        @review = Review.new(review_params)
        if @review.save
            redirect_to game_path(@review.game_id)
        else
            render action: :new
        end
    end

    def edit
    end

    private
    def review_params
        params.require(:review).permit(:play_hour, :body, :score, :good_point, :bad_point, :classification_flag).merge(user_id: current_user.id, game_id: params[:game_id])
    end

    def review_set
        @review = Review.find(params[:id])
    end

    def game_set
        @game = Game.find(params[:game_id])
    end
end
