class EnablePostgisExtension < ActiveRecord::Migration
  def change
    enable_extension 'postgis' unless extension_enabled?('postgis')
  end
end
