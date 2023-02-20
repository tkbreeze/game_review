FactoryBot.define do
  factory :review do
    play_hour {20.0}
    sequence(:body) {|n| "test#{n}"}
    score {8.4}
    classification_flag {"f"}
    good_point {0}
    bad_point {0}
    sequence(:title) {|n| "test_title#{n}"}
    association :user
    association :game
  end
end