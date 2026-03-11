class GamesController < ApplicationController
  def index
    @games = Game.all

    # タイトル検索（アクセント記号・大文字小文字を無視した曖昧検索）
    if params[:q].present?
      normalized_q = Game.normalize_for_search(params[:q])
      @games = @games.where("normalized_title LIKE ?", "%#{normalized_q}%")
    end

    # フィルタ（サブクエリで重複を回避）
    if params[:name].present?
      @games = @games.where(id: GameHardware.where(hardware_id: params[:name]).select(:game_id))
    end

    if params[:genre_id].present?
      @games = @games.where(id: GameGenre.where(genre_id: params[:genre_id]).select(:game_id))
    end

    if params[:maker].present?
      @games = @games.where(maker: params[:maker])
    end

    # 注目フィルタ
    if params[:trending] == "1"
      @games = @games.where("trending_score > 0")
    end

    # ソート
    @games = case params[:sort]
             when "media_score"
               # メディアスコア(Metacritic)降順。スコアなしは末尾へ
               @games.order(Arel.sql("CASE WHEN aggregated_rating IS NULL THEN 1 ELSE 0 END, aggregated_rating DESC"))
             when "user_score"
               # レビュー平均スコア降順。レビューなしは末尾へ
               @games.joins(
                 "LEFT JOIN (SELECT game_id, AVG(score) AS avg_score FROM reviews GROUP BY game_id) " \
                 "AS avg_reviews ON avg_reviews.game_id = games.id"
               ).order(Arel.sql("CASE WHEN avg_reviews.avg_score IS NULL THEN 1 ELSE 0 END, avg_reviews.avg_score DESC"))
             when "trending"
               @games.order(trending_score: :desc)
             else
               @games.order(release_date: :desc)
             end

    @games = @games.page(params[:page]).per(10)
  end

  def show
    @game = Game.find(params[:id])
    @hardwares = Hardware.joins(:game_hardwares).where(game_hardwares: { game_id: @game })
    @genres    = Genre.joins(:game_genres).where(game_genres: { game_id: @game })
    @reviews   = Review.where(game_id: @game).includes(:user).order(created_at: :desc)
    @reviews_include_body = Review.where(game_id: @game).where.not(title: '').includes(:user).order(created_at: :desc)
    @score_color        = score_color(@reviews)
    @reviews_good_graph = Review.where(game_id: @game).where.not(good_point: 0)
    @reviews_bad_graph  = Review.where(game_id: @game).where.not(bad_point: 0)
  end

  private

  def game_params
    params.require(:game).permit(hardware_ids: [])
  end

  def score_color(review)
    return unless review.count != 0

    if review.average(:score) >= 8
      "bg-success"
    elsif review.average(:score) >= 4
      "bg-warning"
    else
      "bg-danger"
    end
  end
end
