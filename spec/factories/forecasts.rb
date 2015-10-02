FactoryGirl.define do

  factory :forecast do
    association :station, factory: :station
    forecasted_datetime { DateTime.now }

    # 2.25 parts per million:
    ozone do
      2.25
    end
    
  end

end
