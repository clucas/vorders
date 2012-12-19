# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:random_order_name) {|n| Faker::Name.name }

  factory :order do
    name { generate(:random_order_name) }
    reason ""
    # status "draft"
    order_on Date.parse(Time.now.utc.to_s)
  end
end
