require 'csv'
require 'msgpack'

class ForecastIntegrationDemo

  def self.temp_dir
    @temp_dir ||= File.join Rails.root, 'tmp'
  end

  def self.cycles_dir
    @cycles_dir ||= begin
      dir = File.join temp_dir, 'demo-cycles'
      Dir.mkdir(dir) unless Dir.exist?(dir)
      dir
    end
  end

  def self.cycles_archive_path
    "#{cycles_dir}.tar.bz2"
  end

  def self.clear_cycles_dir!
    Dir[File.join(cycles_dir, '*.*')].each do |path_to_delete|
      File.delete path_to_delete
    end
  end

  def self.get_station_mapping
    @station_mapping ||= begin
      Hash[Station.active.order(id: :asc).pluck(:short_name, :id)]
    end
  end

  def self.get_station_short_name(station_id)
    get_station_mapping
  end

  def self.get_station_id(station_short_name)
    if (station_id = get_station_mapping[station_short_name])
      station_id
    else
      raise "No station id found for \"#{station_short_name}\""
    end
  end

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

  # Copies the CSV files from a temporary folder into the 'db/demo-cicles'
  # folder, renamed with the last datetime of the cicle measurements:
  def self.import_original_csvs_to_project
    # 1: Clear the target folder:
    clear_cycles_dir!

    # 2: Set the source folder, and count the csv files:
    source_folder = File.join temp_dir, 'demo-cicles-import'
    source_file_count = Dir[File.join(source_folder, '*.csv')].count

    # 3: Load each CSV file and create a MessagePack dump on the target folder:
    puts "======= Generating dump files... ===================================="
    (1..source_file_count).each do |cycle_number|
      source_file_path = File.join source_folder, "ciclo#{cycle_number}.csv"
      source_data = CSV.parse File.read(source_file_path), headers: true

      target_data = source_data.map do |row|
        # Set the initial measurement hash:
        measurement = {
          "measured_at" => ([
            row.delete("fecha").last, row.delete("hora").last.rjust(2,'0')
          ].join('T') + ':00:00.00-06:00'),
          "station_id" => get_station_id(row.delete("sitio").last)
        }

        measurement = row.headers.inject(measurement) do |msrmnt, field_name|
          value = row.field(field_name)

          msrmnt[get_api_attribute_name(field_name)] = if value == "NA"
            nil
          else
            value.to_f
          end

          msrmnt
        end
      end

      dump_name = target_data.map do |x|
        Time.parse(x["measured_at"])
      end.max.strftime("%Y-%m-%d-%H") + '.msgpack'

      dump_path = File.join cycles_dir, dump_name

      File.write dump_path, MessagePack.pack(target_data), mode: 'wb'
    end

    # 4: Archive & Compress:
    puts "======= Archiving and compressing dump files... ====================="
    File.delete(cycles_archive_path) if File.exist?(cycles_archive_path)
    system_call_result = %x[ tar cjf #{cycles_archive_path} -C #{cycles_dir} . ]

    # 5: Clear the folder again:
    puts "======= Clearing generated dump files... ============================"
    clear_cycles_dir!

    puts "======= Finished ===================================================="
  end

  def self.expand_demo_cycles!
    raise "Demo cycles archive not found" unless File.exist?(cycles_archive_path)
    clear_cycles_dir!
    system_call_result = %x[ tar xf #{cycles_archive_path} -C #{cycles_dir} ]
  end

  def self.import_demo_cycle_measurements!
    # Get the Datetime of the last measurement:
    msrmnt_ids = Station.active.pluck(:last_measurement_id)
    lst_msrmnt_dttms = Measurement.where(id: msrmnt_ids).map(&:measured_at).uniq

    # If the list of datetimes is:
    #  - empty: There are no measurements, we'll start on cycle 1
    #  - contains only 1 element: All the measurements are from the same
    #    datetime, so we'll consider the set complete.
    raise "Station last measurement set incomplete" \
      unless lst_msrmnt_dttms.empty? || lst_msrmnt_dttms.count == 1

    # Get the cycle corresponding to 6 hours after the last measurement:
    cycle_dump_name = if lst_msrmnt_dttms.empty?
      # Gen the datetime previous to the first measurement in the first cycle,
      # which would be one hour before the first measurement in cycle 1:
      Time.parse('2014-06-01T00:00:00.00-06:00').advance(hours: -1)
    else
      lst_msrmnt_dttms.last
    end.advance(hours: 6).getlocal('-06:00').strftime("%Y-%m-%d-%H") + '.msgpack'

    print "Loading dump '#{cycle_dump_name}' to database... "

    cycle_data = MessagePack.unpack(
      File.read(File.join cycles_dir, cycle_dump_name)
    )

    cycle_data.each do |measurement_attributes|
      Measurement.create! measurement_attributes
    end

    exit_message = 'done!'
  ensure
    exit_message ||= 'failed!'
    puts exit_message
  end

end
