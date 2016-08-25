  require 'net/http'
  require 'uri'

  module Request
    def self.build(uri, config, params = {})
      verb = config['verb']
      if verb.upcase == 'GET'
        if params.empty? == false
          uri.query = URI.encode_www_form(params)
          path = "#{uri.path}#{'?' + uri.query if uri.query}"
        else
          if uri.path == ''
            path = '/'
          else
            path = uri.path
          end
        end

        request = Net::HTTP::Get.new path
      elsif verb.upcase == 'POST'
        if uri.path != ''
          path = uri.path
        else
          path = '/'
        end

        request = Net::HTTP::Post.new(path)
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
