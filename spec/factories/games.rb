FactoryBot.define do
  factory :game do
    release_date {2022-10-31}
    sequence(:title) {|n| "test#{n}"}
    maker {"test_maker"}
  end
end