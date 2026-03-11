class Game < ApplicationRecord
  has_many :game_hardwares, dependent: :destroy
  has_many :hardwares, through: :game_hardwares, dependent: :destroy
  has_many :game_genres, dependent: :destroy
  has_many :genres, through: :game_genres
  has_many :reviews, dependent: :destroy

  mount_uploader :cover, CoverUploader

  before_save :set_normalized_title

  # 検索用: アクセント記号・大文字小文字を除去して正規化
  # 例) "Pokémon" → "pokemon", "FINAL FANTASY" → "final fantasy"
  def self.normalize_for_search(str)
    str.unicode_normalize(:nfkd).gsub(/\p{Mn}/, '').downcase
  end

  private

  def set_normalized_title
    self.normalized_title = self.class.normalize_for_search(title.to_s)
  end
end
