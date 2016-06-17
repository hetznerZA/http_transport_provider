require 'soar_transport_api'
require 'uri'
require 'net/http'
require 'openssl'
require 'http_transport_provider/configuration_validation'
require 'http_transport_provider/request'

class HttpTransportProvider < SoarTransportApi::TransportAPI
  class NotConfigured < StandardError; end

  def initialize(transport_identifier)
    super(transport_identifier)
    @message_response = []
  end

  def configure(config)
    if ConfigurationValidation.valid?(config)
      @configuration = config
    end
  end


  def send_message(uri, message)
    #TODO: Message validation
    uri = URI::parse uri
    raise NotConfigured if @configuration.nil?

    request = Request.build(uri, @configuration, message['body'])
    response = connection(uri).request(request)

    @message_response.push(response)
    map_response_code_to_delivery_status(response.code)
  end

  def receive_message
    @message_response.pop.body
  end

  private
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
    elsif code == '508'
      DELIVERY_PENDING
    elsif code == '208'
      "Delivery status unkown"
    else
      "Delivery status unsupported"
    end
  end
end
