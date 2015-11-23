# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Station data that need to be present before processing in ForecastEngine:

[
  { code: "sureste-la-pastora", name: "Sureste La Pastora",
  short_name: "La Pastora", lonlat: "POINT (-100.24958 25.66827)" },
  { code: "noreste-san-nicolas", name: "Noreste San Nicolás",
  short_name: "San Nicolas", lonlat: "POINT (-100.25502 25.74543)" },
  { code: "centro-obispado", name: "Centro Obispado",
    short_name: "Obispado", lonlat: "POINT (-100.335847 25.67602)" },
  { code: "noroeste-san-bernabe", name: "Noroeste San Bernabé",
    short_name: "San Bernabe", lonlat: "POINT (-100.365974 25.75712)" },
  { code: "suroeste-santa-catarina", name: "Suroeste Santa Catarina",
    short_name: "Santa Catarina", lonlat: "POINT (-100.460037 25.67536)" },
].each do |station_attributes|
  station_code = station_attributes.delete :code
  Station.create_with(station_attributes.merge(is_forecastable: true))
    .find_or_create_by(code: station_code)
end
