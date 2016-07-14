module JsonApiHelper
  def json_api_params
    collected_params = params.slice(:page) # Pagination params passed as it is
    collected_params.merge! json_api_related_resources_inclusion_params
    collected_params.merge! json_api_sorting_params
    collected_params.merge! json_api_sparse_fieldsets_params
    collected_params.with_indifferent_access
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

  protected

    def json_api_sparse_fieldsets_params
      return {} unless params.key?(:fields)
      {
        fields: params[:fields].each_with_object({}) do |fieldset, fieldsets_params|
          resource_type, resource_fields = fieldset
          fieldsets_params[resource_type] = resource_fields.split(",")
        end
      }
    end

    def json_api_sorting_params
      return {} unless params.key?(:sort)
      {
        sort: params[:sort].split(",").each_with_object({}) do |criteria, sorting_params|
          sorting_order = (criteria[0] == '-') ? :desc : :asc
          sorting_field = ((sorting_order == :desc) ? criteria[1..-1] : criteria).to_sym
          sorting_params[sorting_field] = sorting_order
        end
      }
    end

    def json_api_related_resources_inclusion_params
      return {} unless params.key?(:include)
      { include: params[:include].split(",").map(&:to_sym) }
    end
end
