# Configure ActiveSupport to not wrap BigDecimal represetations in double-quotes:
# ActiveSupport.encode_big_decimal_as_string = false

# Configure ActiveModel::Serializer to use the json_api format:
ActiveModel::Serializer.config.adapter = :json_api
ActiveModel::Serializer.config.key_transform = :underscore
