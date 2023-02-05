# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

#game
BotW = Game.create(title:'ゼルダの伝説 ブレス オブ ザ ワイルド', release_date: '2017-03-03', maker: '任天堂')
ELDEN_RING = Game.create(title:'ELDEN RING',release_date:'2022-02-25', maker: 'フロム・ソフトウェア')
Rise = Game.create(title:'モンスターハンターライズ',release_date:'2021-03-26',maker: 'カプコン')

#hardware
Switch = Hardware.create(name: 'Nintendo Switch')
PS5 = Hardware.create(name: 'PS5')
XboxX = Hardware.create(name: 'Xbox series X')

#genre
open_world = Genre.create(name: 'オープンワールド')
action_adventure = Genre.create(name: 'アクションアドベンチャー')
action_RPG = Genre.create(name: 'アクションRPG')
hunting_action = Genre.create(name: 'ハンティングアクション')

#gameとhardwareの結びつき
#BotW
GameHardware.create(game: BotW,hardware: Switch)
#ELDEN RING
GameHardware.create(game: ELDEN_RING, hardware: PS5)
GameHardware.create(game: ELDEN_RING, hardware: XboxX)
#モンハンライズ
GameHardware.create(game: Rise, hardware: Switch)
GameHardware.create(game: Rise, hardware: PS5)
GameHardware.create(game: Rise, hardware: XboxX)

#gameとgenreの結びつき
#BotW
GameGenre.create(game: BotW, genre: action_adventure)
GameGenre.create(game: BotW, genre: open_world)
#ELDEN RING
GameGenre.create(game: ELDEN_RING, genre: action_RPG)
GameGenre.create(game: ELDEN_RING, genre: open_world)
#モンハンライズ
GameGenre.create(game: Rise, genre:hunting_action)
GameGenre.create(game: Rise, genre: action_RPG)