FactoryBot.define do
  factory :review do
    play_hour {20.0}
    sequence(:body) {|n| "test#{n}"}
    score {8.4}
    classification_flag {"f"}
    good_point {'not_defined'}
    bad_point {'not_defined'}
    sequence(:title) {|n| "test_title#{n}"}
    association :user
    association :game

    trait :invalid do
      play_hour {nil}
    end
  end
end