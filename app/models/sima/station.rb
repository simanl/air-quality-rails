module Sima
  class Station
    include ActiveModel::Model

    FULL_NAME_PATTERN = /\A((Centro|Norte|Noreste|Este|Sureste|Sur|Suroeste|Oeste|Noroeste)\s*\d*)\s+(.+)\z/i

    TYPE_B_NAME_PATTERN = /\A\[\d+\]\s+(.+)\z/i

    NAME_NORMALIZATION_MAP_A = {
      "NORESTE SAN NICOLAS"  => "Noreste San Nicolás",
      "NOROESTE SAN BERNABE" => "Noroeste San Bernabé",
      "SUROESTE2 SAN PEDRO"  => "Suroeste 2 San Pedro",
      "NOROESTE 2 GARCIA"    => "Noroeste 2 García"
    }

    NAME_NORMALIZATION_MAP_B = {
      "[1] La Pastora"     => "Sureste La Pastora",
      "[2] San Nicolás"    => "Noreste San Nicolás",
      "[3] Obispado"       => "Centro Obispado",
      "[4] Metrorrey"      => "Noroeste San Bernabé",
      "[5] Santa Catarina" => "Suroeste Santa Catarina"
    }

    attr_accessor :name, :short_name, :code, :city, :city_code, :country,
                  :agency, :url, :latitude, :longitude

    def code
      @code ||= name.split.map { |x| I18n.transliterate(x).downcase }.join '-'
    end

    def short_name
      @short_name ||= if (match = name.match(FULL_NAME_PATTERN))
                        match.captures[2]
                      else
                        name
                      end
    end

    class << self
      def from_type_a_data(data, general_attributes = {})
        station_name = normalize_name_type_a(data['name'])
        latitude, longitude = data['location'].split(',').map(&:to_f)

        self.new general_attributes.merge(
          name: station_name, latitude: latitude, longitude: longitude
        )
      end

      def from_type_b_data(data, general_attributes = {})
        station_name = normalize_name_type_b(data['SITIO'])
        # No lat-lng data yet on type B response...
        # TODO: Get Lat-Lng data from type B response as soon as they include it...
        self.new general_attributes.merge(name: station_name)
      end

      protected

        def normalize_name_type_a(given_name)
          if NAME_NORMALIZATION_MAP_A.key?(given_name)
            NAME_NORMALIZATION_MAP_A[given_name]
          else
            given_name.titleize
          end
        end

        def normalize_name_type_b(given_name)
          if NAME_NORMALIZATION_MAP_B.key?(given_name)
            NAME_NORMALIZATION_MAP_B[given_name]
          elsif (match = given_name.match(TYPE_B_NAME_PATTERN))
            match.captures.join
          else
            given_name.titleize
          end
        end
    end
  end
end
