  require 'net/http'
  require 'uri'

  module Request
    def self.build(uri, config, params = {})
      verb = config['verb']
      if verb.upcase == 'GET'
        if params.empty? == false
          uri.query = URI.encode_www_form(params)
        end
        request = Net::HTTP::Get.new uri
      elsif verb.upcase == 'POST'
        request = Net::HTTP::Post.new(uri)
        if params.empty? == false
          request.set_form_data(params)
        end
      end

      if config['credentials'].nil? == false
        request.basic_auth(config['credentials']['username'], config['credentials']['password'])
      end

      #TODO: check if return object is valid net/http request
      request
    end
  end
