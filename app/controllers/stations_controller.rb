class StationsController < ApplicationController

  # GET /stations
  # GET /stations.json
  def index
    @stations = Station.all

    # Sorting:
    @stations = @stations.order(json_api_params[:sort]) if json_api_params.key? :sort

    # Pagination:
    if json_api_params[:page].present?
      # ...
      @stations = @stations.limit(json_api_params[:page][:limit]) if json_api_params[:page].key? :limit
      # ...
    end

    respond_to do |format|
      format.json { render json: @stations }
    end
  end

  # GET /stations/1
  # GET /stations/1.json
  def show
    @station = Station.find(params[:id])

    respond_to do |format|
      format.json { render json: @station }
    end
  end

end
