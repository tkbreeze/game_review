class ReviewsController < ApplicationController
    before_action :authenticate_user!, only: [:new,:edit,:destroy]
    before_action :review_set, only: [:show,:destroy, :edit, :update]
    before_action :game_set

    def new
        if Review.find_by(user_id: current_user.id, game_id: @game)
            redirect_to edit_game_review_path(@game,Review.find_by(user_id: current_user.id))
        else
            @review = Review.new
        end
        #@review.build
    end
    
    def create
        @review = Review.new(review_params)
        if @review.save
            redirect_to game_path(@review.game_id)
        else
            render 'new', status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        if @review.user_id == current_user.id and @review.update(review_params)
            redirect_to game_path(@review.game_id)
        else
            render action: :edit, status: :unprocessable_entity
        end
    end

    def destroy
        if @review.user_id == current_user.id and @review.destroy
            redirect_to game_path(@review.game_id), status: :see_other
        else
            redirect_to game_path(@review.game_id)
        end
    end

    private
    def review_params
        params.require(:review).permit(:title,:play_hour, :body, :score, :good_point, :bad_point, :classification_flag).merge(user_id: current_user.id, game_id: params[:game_id])
    end

    def review_set
        @review = Review.find_by(game_id: params[:game_id], user_id: current_user.id)
    end

    def game_set
        @game = Game.find(params[:game_id])
    end
end
