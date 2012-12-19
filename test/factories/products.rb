# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:random_name) {|n| Faker::Name.name }

  factory :product do
    name { generate(:random_name) }
    net_price 1
    currency "USD"
  end
end
