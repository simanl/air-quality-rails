class MeasurementsController < ApplicationController

  # GET /measurements
  # GET /measurements.json
  def index
    @measurements = Measurement.all

    # Pagination:
    filter_measurements_since!
    limit_measurements!

    respond_to do |format|
      format.json { render json: @measurements }
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

  private

    def filter_measurements_since!
      return unless json_api_params.key?(:page) && json_api_params[:page].key?(:since)
      @measurements = @measurements.since Time.parse(json_api_params[:page][:since])
    end

    def limit_measurements!
      return unless json_api_params.key?(:page) && json_api_params[:page].key?(:limit)
      @measurements = @measurements.limit json_api_params[:page][:limit].to_i
    end

end
