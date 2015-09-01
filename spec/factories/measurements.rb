FactoryGirl.define do

  factory :measurement do
    association :station, factory: :station
    measured_at { DateTime.now }

    factory :measurement_with_imeca_points do
      imeca_points 41
    end
  end

end
