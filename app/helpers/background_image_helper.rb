module BackgroundImageHelper
  # Registers the helper methods available for views.
  def self.included(base)
    base.send :helper_method, :background_image_by_time \
      if base.respond_to? :helper_method
  end

  # Obtains the background image that should be used, depending of the time of
  # the day:
  def background_image_by_time
    image_url "bg_day.jpg"
  end
end
