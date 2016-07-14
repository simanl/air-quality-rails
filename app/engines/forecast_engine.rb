require 'rserve'
require 'rserve/simpler'

class ForecastEngine

  FIELD_NAME_TRANSLATIONS = {
    "CO"    => "carbon_monoxide",
    "NO"    => "nitric_oxide",
    "NO2"   => "nitrogen_dioxide",
    "NOX"   => "nitrogen_oxides",
    "O3"    => "ozone",
    "PM10"  => "toracic_particles",
    "PM2.5" => "respirable_particles",
    "PRS"   => "atmospheric_pressure",
    "RAINF" => "precipitation",
    "HR"    => "relative_humidity",
    "SO2"   => "sulfur_dioxide",
    "SR"    => "solar_radiation",
    "TOUT"  => "temperature",
    "WS"    => "wind_speed",
    "WDR"   => "wind_direction"
  }

  OUTPUT_FIELD_TRANSLATIONS = {
    "contaminante" => "pollutant",
    "sitio"        => "site",
    "pronostico"   => "quality"
  }

  def self.get_api_attribute_name(engine_field_name)
    if (api_attribute_name = FIELD_NAME_TRANSLATIONS[engine_field_name])
      api_attribute_name.to_sym
    else
      raise "No API attribute name found for \"#{engine_field_name}\""
    end
  end

  def self.get_api_attribute_sym(engine_field_name)
    get_api_attribute_name(engine_field_name).to_sym
  end

  def self.get_engine_field_name(api_attrib_name)
    if (engine_field_name = FIELD_NAME_TRANSLATIONS.key(api_attrib_name.to_s))
      engine_field_name
    else
      raise "No Engine field name found for \"#{api_attrib_name}\""
    end
  end

  delegate :get_api_attribute_name, :get_api_attribute_sym, :get_engine_field_name,
    to: :class

  NUMERIC_FIELDS = %w(CO NO NO2 NOX O3 PM10 PM2.5 PRS RAINF HR SO2 SR TOUT WS WDR)

  def self.convert_to_input_dataframe(given_input_data)

    # Inicializar el DataFrame:
    data_frame = %w(fecha hora sitio CO NO NO2 NOX O3 PM10 PM2.5 PRS RAINF HR
    SO2 SR TOUT WS WDR).inject({}) { |df, header| df[header] = []; df }

    # Llenar el dataframe:
    given_input_data.inject(data_frame) do |df, msrmnt|
      datetime = msrmnt.measured_at.to_time.getlocal('-06:00')

      df['fecha'] << datetime.strftime('%Y-%m-%d')
      df['hora']  << datetime.hour.to_i
      df['sitio'] << msrmnt.station.short_name

      %w(CO NO NO2 NOX O3 PM10 PM2.5 PRS
      RAINF HR SO2 SR TOUT WS WDR).each do |field_name|
        df[field_name] << msrmnt.try(get_api_attribute_sym field_name)
      end

      df
    end
  end

  def self.convert_to_output_data(given_output_df)

    row_size = given_output_df.map { |column| column.size }.uniq.max

    blank_row = %w(site start_at end_at
    pollutant index category).inject({}) do |hsh, name|
      hsh[name.to_sym] = nil
      hsh
    end

    (0..(row_size-1)).inject([]) do |data, row_index|
      forecast = blank_row.dup

      # The rserve client translates the remote date into the number of days
      # since epoch...
      # The forecast engine behind the rserve server is expecting datetimes
      # to be expressed always as -06:00:
      date = Time.parse('1970-01-01T00:00:00-06:00')
        .advance(days: given_output_df['fecha'][row_index].to_i)

      start_hour, end_hour = given_output_df['periodo'][row_index].split(' a ')
        .map(&:to_i)

      forecast.keys.each do |field_name|
        forecast[field_name] = case field_name
        when :site then given_output_df['sitio'][row_index]
        when :start_at then date.advance(hours: start_hour)
        when :end_at then date.advance(hours: (end_hour + 1))
        when :pollutant then
          contaminante = given_output_df['contaminante'][row_index]
          case contaminante
          when 'O3' then :ozone
          when 'PM10' then :toracic_particles
          when 'PM2.5' then :respirable_particles
          end
        when :index then given_output_df['pronostico'][row_index]
        when :category then
          if (categoria_pronosticada = given_output_df['categoria'][row_index])
            case categoria_pronosticada
            when 'buena'   then :good
            when 'regular' then :regular
            when 'mala'    then :bad
            else
              puts "======= Unknown quality value '#{categoria_pronosticada}' - assigning as is ======="
              categoria_pronosticada
            end
          end
        end
      end

      data << forecast
      data
    end
  end

  attr_reader :engine_uri

  # Example initializer, connects to the remote R host specified in the
  # FORECAST_ENGINE_URL environment variable:
  def initialize
    @engine_uri = URI(ENV.fetch 'FORECAST_ENGINE_URL')
  end

  def update_forecasts(input_data)

    # Generate an input "dataframe" (think like, a spreadsheet)
    input_df = convert_to_input_dataframe(input_data)

    conn = Rserve::Simpler.new hostname: engine_uri.host

    # Use the remote engine to generate an output dataframe:
    output_df = conn.converse("tabla.entrada" => input_df.to_dataframe) do
      'SPCA()'
    end

    # SPCA method completed successfully on engine... tell it to save the data:
    conn.command 'post()' if output_df

    # Return a translated array of hashes:
    return convert_to_output_data(output_df)
  ensure
    conn.close if conn && conn.connected?
  end

  private

    delegate :convert_to_input_dataframe, :convert_to_output_data, to: :class

end
