module HtmlStylingHelper
  # Registers the helper methods available for views.
  def self.included(base)
    base.send :helper_method, :action_as_html_classes \
      if base.respond_to? :helper_method
  end

  # Obtains the controller + action names to add them as classes at the <body> tag:
  def action_as_html_classes
    params.slice(:controller, :action)
      .values
      .map { |x| x.dasherize.tr("/", "-") }
      .join " "
  end
end
