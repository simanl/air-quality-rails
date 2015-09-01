module JsonApiHelper

  def json_api_params
    @_json_api_params ||= begin
      permitted_params = params.slice(:include, :page, :sort, :fields)

      ##########################################################################
      # Parse comma-separated lists to an array:
      [:include, :sort].each do |param_name|
        permitted_params[param_name] = permitted_params[param_name].split ',' \
          if permitted_params.key? param_name
      end

      # Parse the comma-separated lists on the sparse-fields key to an array:
      permitted_params[:fields].each do |type, fieldlist|
        permitted_params[:fields][type] = permitted_params[:fields][type].split ','
      end if permitted_params.key? :fields

      ##########################################################################
      # Parse sort directions:
      permitted_params[:sort] = permitted_params[:sort].inject({}) do |parsed_sort, sort_element|
        sort_order = sort_element[0] == '-' ? :desc : :asc
        sort_field = sort_order == :desc ? sort_element[1..-1] : sort_element
        parsed_sort[sort_field] = sort_order
        parsed_sort
      end if permitted_params.key? :sort

      permitted_params[:include].map!(&:to_sym) if permitted_params.key? :include

      permitted_params

    end
  end

  def json_api_related_resources(records, includes)
    ActiveRecord::Associations::Preloader.new
      .preload(@stations, includes)
      .map(&:preloaded_records)
      .flatten
  end

  def json_api_format?
    params[:format] == :jsonapi
  end

  def json_api_association_not_found
    render plain: "400 Bad Request", status: 400
  end

end
