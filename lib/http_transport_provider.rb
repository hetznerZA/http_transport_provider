require 'soar_transport_api'
require 'uri'
require 'net/http'

class HttpTransportProvider < SoarTransportApi::TransportAPI
  def initialize(transport_identifier)
    super(transport_identifier)
    @message_response = []
  end

  def send_message(uri, message)
    MessageValidation.valid?(message)
    uri = URI::parse uri

    response = connection(uri).request Request.build(uri, message['options']['http_verb'], message['body'], message['credentials'])
    
    @message_response.push(response)
    map_response_code_to_delivery_status(response.code)
  end

  def receive_message
    @message_response.pop.body
  end

  private
  #TODO: connection pooling
  #TODO: enable/disable verify_mode
  def connection(uri)
    connection = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE)
  end

  def map_response_code_to_delivery_status(code)
    if code == '200'
      DELIVERY_SUCCESS
    elsif code == '408'
      DELIVERY_TIMEOUT
    elsif code == '401'
      DELIVERY_REJECTED
    elsif code == '500'
      DELIVERY_FAILURE
    else
      #TODO: Perhaps add as constant to soar_transport_api gem
      "Delivery status unkown"
    end
  end
end
