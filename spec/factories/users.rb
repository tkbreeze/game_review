FactoryBot.define do
  factory :user do
    sequence(:email) {|n| "tester#{n}@exaple.com"}
    password {"dededede45"}
    name {"test_name"}
  end
end