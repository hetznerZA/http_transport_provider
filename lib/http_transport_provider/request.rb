  require 'net/http'
  require 'uri'

  module Request
    def self.build(uri, verb, params = nil, credentials = nil)
      if verb.upcase == 'GET'
        if params.nil? == false
          uri.query = URI.encode_www_form(params)
        end

        request = Net::HTTP::Get.new uri
      elsif verb.upcase == 'POST'
        request = Net::HTTP::Post.new(uri)
        if params.nil? == false
          request.set_form_data(params)
        end
      end

      if credentials.nil? == false
        request.basic_auth(credentials['username'], credentials['password'])
      end

      request
    end
  end
