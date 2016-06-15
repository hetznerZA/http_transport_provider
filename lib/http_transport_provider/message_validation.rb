class MessageInvalidError < StandardError
end

module MessageValidation
  def self.valid?(message)
    if message['options'].nil?|| message['options']['http_verb'].nil? || message['options']['http_verb'].empty?
      #TODO: Include message as to why the error was raised e.g. Missing value options['http_verb']
      raise MessageInvalidError
    end
    true
  end
end
