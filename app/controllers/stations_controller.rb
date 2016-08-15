class StationsController < ApplicationController
  before_action :set_station, only: [:show]

  # GET /stations
  # GET /stations.json
  def index
    set_stations_initial_scope!

    sort_stations_by_given_distance!
    sort_stations_by_given_criteria!

    # Pagination:
    paginate_stations!

    # Associations 'current_forecasts' and 'last_measurement' are always eager
    # loaded... however, full data will only be included if using the 'include'
    # parameter:
    eager_load_associations!

    respond_to do |format|
      format.json { render json: @stations, fields: json_api_params[:fields], include: params[:include] }
      format.jsonapi { render json: @stations, fields: json_api_params[:fields], include: params[:include], key_transform: :dash }
    end
  end

  # GET /stations/1
  # GET /stations/1.json
  def show
    respond_to do |format|
      format.json { render json: @station, fields: json_api_params[:fields], include: params[:include] }
      format.jsonapi { render json: @station, fields: json_api_params[:fields], include: params[:include], key_transform: :dash }
    end
  end

  protected

    def set_station
      if params[:id]
        @station = Station.find(params[:id])
      elsif params[:nearest_from] || params[:latlon]
        latitude, longitude = parse_latlon_param(params[:nearest_from] || params[:latlon])
        @station = Station.nearest_from(latitude, longitude).limit(1).first
      end
    end

    def parse_latlon_param(param)
      param.split(",").map { |numeric| BigDecimal.new numeric }
    end

    def set_stations_initial_scope!
      @stations = Station.all
    end

    def sort_stations_by_given_distance!
      return unless params[:nearest_from].present?
      latitude, longitude = parse_latlon_param params[:nearest_from]
      @stations = @stations.nearest_from latitude, longitude
    end

    def sort_stations_by_given_criteria!
      return unless json_api_params.key? :sort
      @stations = @stations.order json_api_params[:sort]
    end

    def paginate_stations!
      limit_stations! # limits by given pagination or default
      return unless json_api_params[:page].present?
    end

    def limit_stations!
      if json_api_params.key?(:page) && json_api_params[:page][:limit]
        station_limit =json_api_params[:page][:limit].to_i
      else
        station_limit = 20
      end

      @stations = @stations.limit station_limit
    end

    def eager_load_associations!
      @stations = @stations.includes :last_measurement, :current_forecasts
    end
end
