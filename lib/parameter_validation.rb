class ParameterValidation
  def validate(body, requirements)
    # TODO: Create a validation class to handle this, it's getting too complicated
    requirements.each do |req_set|
      value = body.dig(*req_set[:path])
      raise ArgumentError, req_set[:error_message] unless req_set[:validation].include?(value)
      if req_set[:condition]
        # ?????
      end
    end

    true
  end
end