class ForecastsController < ApplicationController

  # GET /forecasts
  # GET /forecasts.json
  def index
    @forecasts = Forecast.all

    # Pagination:
    if json_api_params[:page].present?
      @forecasts = @forecasts.since(json_api_params[:page][:since]) if json_api_params[:page].key? :since
      @forecasts = @forecasts.limit(json_api_params[:page][:limit]) if json_api_params[:page].key? :limit
      # ...
    end

    respond_to do |format|
      format.json { render json: @forecasts, serializer: ForecastWithStationSerializer }
    end
  end

  # GET /forecasts/1
  # GET /forecasts/1.json
  def show
    @forecast = Forecast.find(params[:id])

    respond_to do |format|
      format.json { render json: @forecast, serializer: ForecastWithStationSerializer }
    end
  end

end
