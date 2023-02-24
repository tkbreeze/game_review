class GamesController < ApplicationController
    def index
        @games = params[:name].present? ? Hardware.find(params[:name]).games.order(release_date: :desc).page(params[:page]).per(5) : Game.order(release_date: :desc).page(params[:page]).per(5)
        #@hardwares = Hardware.where(id: GameHardware.where(game_id: Game.where(id: @games)))
        #@genres = Genre.where(id: GameGenre.where(game_id: Game.where(id: @games)))
    end

    def show
        @game = Game.find(params[:id])
        @hardwares = Hardware.joins(:game_hardwares).where(game_hardwares: {game_id: @game})
        #@hardware = Hardware.where(game_id: @game)
        @genres = Genre.joins(:game_genres).where(game_genres: {game_id: @game})
        @reviews = Review.where(game_id: @game).includes(:user).order(created_at: :desc)
        @score_color = score_color(@reviews)
        @reviews_good_graph = Review.where(game_id: @game).where.not(good_point: "not_defined")
        @reviews_bad_graph = Review.where(game_id: @game).where.not(bad_point: "not_defined")
    end

    private
    def game_params
        params.require(:game).permit(hardware_ids: [])
    end

    def score_color(review)
        if review.average(:score) >= 8
            return "bg-success"
          elseif review.average(:score) >= 4
            return "bg-warning"
          else
            return "bg-danger"
        end
    end
end
