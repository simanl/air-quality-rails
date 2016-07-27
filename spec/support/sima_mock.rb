class SimaMock
  RECORDED_RESPONSE_PAIRS = {
    ideal_scenario: {
      PollutionServer: "1_ideal_response.json",
      simaservernlpro: "1_ideal_response.json"
    },

    last_before_change: {
      PollutionServer: "2016-07-26T21:52:55+0000.json",
      simaservernlpro: "2016-07-26T21:52:55+0000.json"
    },

    response_a_just_changed_timestamp: {
      PollutionServer: "2016-07-26T21:55:03+0000.json",
      simaservernlpro: "2016-07-26T21:52:55+0000.json" # response_b hasn't changed
    },

    response_a_just_updated_some_values: {
      PollutionServer: "2016-07-26T21:58:23+0000.json",
      simaservernlpro: "2016-07-26T21:52:55+0000.json"
    },

    response_a_just_updated_some_values_again: {
      PollutionServer: "2016-07-26T22:03:04+0000.json",
      simaservernlpro: "2016-07-26T21:52:55+0000.json"
    },

    response_a_started_reporting_imeca: {
      PollutionServer: "2016-07-26T22:07:45+0000.json",
      simaservernlpro: "2016-07-26T21:52:55+0000.json"
    },

    response_a_just_updated_some_imeca: {
      PollutionServer: "2016-07-26T22:10:06+0000.json",
      simaservernlpro: "2016-07-26T21:52:55+0000.json"
    },

    # Happy Path:
    # response_a_just_updated_some_imeca_again
    response_b_just_updated_and_matched_response_a_timestamp: {
      PollutionServer: "2016-07-26T22:12:34+0000.json",
      simaservernlpro: "2016-07-26T22:12:34+0000.json"
    },

    # This is step 1 (response_a_just_changed_timestamp) of next cycle:
    response_a_just_changed_to_next_timestamp: {
      PollutionServer: "2016-07-26T22:56:02+0000.json",
      simaservernlpro: "2016-07-26T22:12:34+0000.json"
    }
  }.freeze

  class ResponsePair
    attr_reader :scenario_name
    def initialize(given_scenario_name)
      puts "initializing ResponsePair '#{given_scenario_name}'"
      @scenario_name = given_scenario_name
    end

    def response_a
      ::SimaMock.mock_response scenario_name, :PollutionServer
    end

    def response_b
      ::SimaMock.mock_response scenario_name, :simaservernlpro
    end
  end

  RECORDED_RESPONSE_PAIRS.keys.each do |scenario_name|
    define_singleton_method scenario_name do
      @response_pairs = {} if @response_pairs.nil?
      @response_pairs[scenario_name] = ResponsePair.new(scenario_name) \
        unless @response_pairs.key?(scenario_name)
      @response_pairs[scenario_name]
    end
  end

  def self.mock_response(given_scenario_name, given_response_type)
    # Class Instance Variable (I don't want to deal with thread sync)
    @scenarios = {} if @scenarios.nil?

    given_scenario_name = given_scenario_name.to_sym
    given_response_type = given_response_type.to_sym

    raise "Undefined scenario '#{given_scenario_name}'" \
      unless RECORDED_RESPONSE_PAIRS.key? given_scenario_name

    raise "Undefined response '#{given_response_type}'" \
      unless RECORDED_RESPONSE_PAIRS[given_scenario_name].key? given_response_type

    @scenarios[given_scenario_name] = {} unless @scenarios.key? given_scenario_name

    unless @scenarios[given_scenario_name].key? given_response_type
      file_name = RECORDED_RESPONSE_PAIRS[given_scenario_name][given_response_type]
      file_path = Rails.root.join "spec", "fixtures", "sima_responses", given_response_type.to_s, file_name
      @scenarios[given_scenario_name][given_response_type] = File.read file_path
    end

    @scenarios[given_scenario_name][given_response_type]
  end
end
