class Admin::DashboardController < AdminController
  def show
    @latest_measurements = Measurement.includes(:station).latest
  end
end
