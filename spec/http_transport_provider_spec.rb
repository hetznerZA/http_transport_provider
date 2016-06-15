require 'spec_helper'
require 'webmock/rspec'

describe HttpTransportProvider do
  let(:uri) {"http://localhost:3000"}
  let(:htp) {HttpTransportProvider.new('test-indentifier')}


  context "#initialize" do
    it "remembers the provided identifier" do
      expect(htp.transport_identifier). to eql "test-indentifier"
    end
  end

  context "Configuring provider" do
    context "Given valid configuration" do
      it "remembers and returns the configuration" do
        config = {'verb' => 'GET'}
        expect(htp.configure(config)).to eql config
      end
    end

    context "Given invalid configuration" do
      context "missing a required keyword" do
        it "raise a ConfigurationValidation::MissingKeywordError" do
          config = {'missing' => 'keyword'}
          expect{htp.configure(config)}.to raise_error ConfigurationValidation::MissingKeywordError
        end
      end

      context "with a invalid keyword" do
        it "raises a ConfigurationValidation::ValueError" do
          config = {'verb' => 'GET', 'invalid_key' => 'value'}
          expect{htp.configure(config)}.to raise_error ConfigurationValidation::InvalidKeywordError
        end
      end

      context "with a invalid value" do
        it "raises a ConfigurationValidation::ValueError" do
          config = {'verb' => 'value'}
          expect{htp.configure(config)}.to raise_error ConfigurationValidation::InvalidValueError
        end
      end
    end
  end

  context "#send_message" do
    context "Given a properly configure provider" do
      context "Support different HTTP verbs" do
        it "GET without parameters" do
          config = {'verb' => 'GET'}
          message = {'body' => {}}
          htp.configure(config)

          stub_request(:get, uri)
          htp.send_message(uri, message)
        end

        it "GET with parameters" do
          message = {'body' => {'search' => 'test_search_value', 'id' => '1'}}
          config = {'verb' => 'GET'}
          htp.configure(config)

          stub_request(:get, "http://localhost:3000/?id=1&search=test_search_value")
          htp.send_message(uri, message)
        end

        it "POST" do
          message = { 'body' => {'id' => 1}, 'options' => {'http_verb' => 'POST'} }
          config = {'verb' => 'POST'}
          htp.configure(config)

          stub_request(:post, "http://localhost:3000/").with(:body => {"id"=>"1"})
          htp.send_message(uri, message)
        end

        it "PUT" do
          pending("not supported")
          stub_request(:put, "http://localhost:3000/")
          expect(false).to eql true
        end

        it "PATCH" do
          pending("not supported")
          stub_request(:patch, "http://localhost:3000/")
          expect(false).to eql true
        end

        it "DELETE" do
          pending("not supported")
          stub_request(:delete, "http://localhost:3000/")
          expect(false).to eql true
        end
      end
    end

    it "Allow Basic auth given credentials options" do
      message = {'body' => {'id' => 1}}
      config = {'verb' => 'POST', 'credentials' => {'username' => 'user', 'password' => 'secret'}}
      htp.configure(config)

      stub_request(:post, "http://localhost:3000/").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic dXNlcjpzZWNyZXQ=', 'Host'=>'localhost:3000', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "", :headers => {})

      htp.send_message(uri, message)
    end

    it "Allows Https connections" do
      https_uri = "https://example.com"
      config = {'verb' => 'GET'}
      message = {'body' => {}}
      htp.configure(config)

      stub_request(:get, https_uri)
      htp.send_message(https_uri, message)
    end

    context "When a message was sent" do
      it "return 'Delivered successfull'" do
        config = {'verb' => 'GET'}
        message = {'body' => {}}
        htp.configure(config)

        stub_request(:get, "http://localhost:3000/").to_return(:status => 200, :body => "", :headers => {})

        #TODO: Bump soar_transport_api version to fix spelling mistake
        expect(htp.send_message(uri, message)).to eql 'Delivered successful'
      end

      it "return 'Delivered failure'" do
        config = {'verb' => 'GET'}
        message = {'body' => {}}
        htp.configure(config)
        stub_request(:get, "http://localhost:3000/").to_return(:status => 500, :body => "", :headers => {})

        expect(htp.send_message(uri, message)).to eql 'Delivery failure'
      end

      it "return 'Delivered timeout'" do
        config = {'verb' => 'GET'}
        message = {'body' => {}}
        htp.configure(config)
        stub_request(:get, "http://localhost:3000/").to_return(:status => 408, :body => "", :headers => {})

        expect(htp.send_message(uri, message)).to eql 'Delivery timeout'
      end

      it "return 'Delivered rejected'" do
        config = {'verb' => 'GET', 'credentials' => {'username' => 'test', 'password' => 'secret'}}
        message = {'body' => {}}
        htp.configure(config)

        stub_request(:get, "http://localhost:3000/").to_return(:status => 401, :body => "", :headers => {})

        expect(htp.send_message(uri, message)).to eql 'Rejected for delivery'
      end

      it "return 'Delivered pending'" do
        pending
        expect(htp.send_message(uri, message)).to eql 'Delivered pending'
      end

      it "return 'Unkown delivery status'" do
        config = {'verb' => 'GET'}
        message = {'body' => {}}
        htp.configure(config)

        stub_request(:get, "http://localhost:3000/").to_return(:status => 1111, :body => "", :headers => {})

        expect(htp.send_message(uri, message)).to eql 'Delivery status unkown'
      end
    end

    it "Given an invalid URI raise an error" do
      expect{htp.send_message({}, {'options' => {'http_verb' => "GET"}})}.to raise_error URI::InvalidURIError
    end

    it "Given a invalid message raise an error" do
      pending('see todo')
      expect{htp.send_message(uri, {'body' => ''})}.to raise_error MessageInvalidError
    end
  end

  context "#receive_message" do
    context "Given a message was sent successfully" do
      it "return the reponse of the last message sent" do
        config = {'verb' => 'GET'}
        message = {'body' => {}}
        htp.configure(config)
        stub_request(:get, "http://localhost:3000/").to_return(:status => 200, :body => "Response body", :headers => {})

        htp.send_message(uri, message)
        expect(htp.receive_message).to eql "Response body"
      end
    end
  end
end
