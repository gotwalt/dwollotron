FactoryGirl.define do
  factory :account do
    sequence(:external_service_id) { |n| n }
    sequence(:access_token) {|n| "oauth-token-#{n}" }
    pin 1234
  end
end