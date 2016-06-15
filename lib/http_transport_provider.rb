require 'soar_transport_api'
require 'uri'
require 'net/http'
require 'openssl'
require 'http_transport_provider/configuration_validation'
require 'http_transport_provider/request'
require 'http_transport_provider/message_validation'

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
    #TODO: do we still need message validation
    #TODO: can message value default to {'body' => {}}??
    #MessageValidation.valid?(message)
    uri = URI::parse uri
    raise NotConfigured if @configuration.nil?
    #TODO: what if @configuraiton not set
    #TODO: test if failure occurs
    request = Request.build(uri, @configuration, message['body'])
    #, @configuration['credentials'] = {})
    response = connection(uri).request(request)

    @message_response.push(response)
    map_response_code_to_delivery_status(response.code)
  end

  def receive_message
    @message_response.pop.body
  end

  private
  #TODO: connection pooling
  #TODO: enable/disable verify_mode
  #TODO: should https config happen in configuration??
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
    else #TODO: 203 unkown,508 pending
      #TODO: Perhaps add as constant to soar_transport_api gem
      "Delivery status unkown" #should be unsupported
    end
  end
end
