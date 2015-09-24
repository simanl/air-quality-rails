class StationsController < ApplicationController

  before_action :set_station, only: [:show]

  # GET /stations
  # GET /stations.json
  def index
    @stations = Station.all

    # Fetch the stations nearest from a given point:
    @stations = @stations.nearest_from(params[:nearest_from]) if params[:nearest_from].present?

    # Sorting:
    @stations = @stations.order(json_api_params[:sort]) if json_api_params.key? :sort

    # Pagination:
    if json_api_params[:page].present?
      # ...
      @stations = @stations.limit(json_api_params[:page][:limit]) if json_api_params[:page].key? :limit
      # ...
    end

    # Inclusion of Related Resources:
    @stations = @stations.includes(:last_measurement)

    respond_to do |format|
      format.json { render json: @stations, fields: params[:fields], include: params[:include] }
    end
  end

  # GET /stations/1
  # GET /stations/1.json
  def show
    respond_to do |format|
      format.json { render json: @station, fields: params[:fields], include: params[:include] }
    end
  end

  protected

    def set_station
      @station = if params[:id]
        Station.find(params[:id])
      elsif params[:nearest_from] || params[:latlon]
        Station.nearest_from(params[:nearest_from] || params[:latlon]).limit(1).first
      end
    end

end
