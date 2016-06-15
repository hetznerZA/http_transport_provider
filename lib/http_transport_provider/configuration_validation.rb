module ConfigurationValidation
  class InvalidKeywordError < StandardError; end
  class InvalidValueError < StandardError; end
  class MissingKeywordError < StandardError; end

  def self.valid?(config)
    raise MissingKeywordError if config.include?('verb') == false

    valid_verbs = ['GET', 'POST']
    raise InvalidValueError if valid_verbs.include?(config['verb'].upcase) == false

    #TODO: expand test to include credentails
    supported_config_keys = ['verb', 'credentials']
    config.each do |k,v|
      raise InvalidKeywordError if supported_config_keys.include?(k) == false
    end

    true
  end
end
