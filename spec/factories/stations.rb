FactoryGirl.define do

  factory :station do
     sequence(:code) { |n| "my-station-#{n}" }
     sequence(:name) { |n| "My Station #{n}" }
     lonlat "POINT(-100.255020 25.74543)"
   end

end
