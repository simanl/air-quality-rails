class MeasurementsController < ApplicationController
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]

  # GET /measurements
  # GET /measurements.json
  def index
    @measurements = Measurement.all

    # Pagination:
    if json_api_params[:page].present?
      @measurements = @measurements.since(json_api_params[:page][:since]) if json_api_params[:page].key? :since
      @measurements = @measurements.limit(json_api_params[:page][:limit]) if json_api_params[:page].key? :limit
      # ...
    end

    respond_to do |format|
      format.json { render json: @measurements }
      format.tab  { render csv: @measurements, serializer: MeasurementWithStationSerializer }
    end
  end

  # GET /measurements/1
  # GET /measurements/1.json
  def show
    @measurement = Measurement.find(params[:id])

    respond_to do |format|
      format.json { render json: @measurement }
    end
  end

end
