class GamesController < ApplicationController
    def index
        @games = Game.order(release_date: :desc).page(params[:page]).per(5)
        @hardwares = Hardware.where(id: GameHardware.where(game_id: Game.where(id: @games)))
        @genres = Genre.where(id: GameGenre.where(game_id: Game.where(id: @games)))
    end

    def show
        @game = Game.find(params[:id])
        @hardwares = Hardware.where(id: GameHardware.where(game_id: Game.where(id: @game)))
        #@hardware = Hardware.where(game_id: @game)
        @genres = Genre.where(id: GameGenre.where(game_id: Game.where(id: @game)))
        @reviews = Review.where(game_id: @game).includes(:user).order(created_at: :desc).page(params[:page]).per(5)
    end
end
