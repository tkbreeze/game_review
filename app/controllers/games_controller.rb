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
        @reviews_good_graph = Review.where(game_id: @game).where.not(good_point: "not_defined")
        @reviews_bad_graph = Review.where(game_id: @game).where.not(bad_point: "not_defined")
    end

    def game_params
        params.require(:game).permit(hardware_ids: [])
    end
end
