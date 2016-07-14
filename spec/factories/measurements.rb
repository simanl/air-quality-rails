FactoryGirl.define do
  factory :measurement do
    association :station, factory: :station
    measured_at { DateTime.now }
  end

  factory :measurement_with_imeca_points, parent: :measurement do
    imeca_points 41
  end
end
