require 'spec_helper'
require 'webmock/rspec'

describe HttpTransportProvider do
  let(:uri) {"http://localhost:3000"}
  let(:htp) {HttpTransportProvider.new('test-indentifier')}

  let(:get_config) {{'verb' => 'GET'}}
  let(:get_config_with_credentials) {{'verb' => 'POST', 'credentials' => {'username' => 'user', 'password' => 'secret'}}}
  let(:post_config) {{'verb' => 'POST'}}

  let(:missing_key_config) {{'missing' => 'keyword'}}
  let(:invalid_key_config) {{'verb' => 'GET', 'invalid_key' => 'value'}}
  let(:invalid_value_config) {{'verb' => 'value'}}

  let(:message) {{'body' => {}}}
  let(:message_with_body) {{'body' => {'id' => 1, 'search' => 'test_search_value'}}}

  context "#initialize" do
    it "remembers the provided identifier" do
      expect(htp.transport_identifier). to eql "test-indentifier"
    end
  end

  context "Configuring provider" do
    context "Given valid configuration" do
      it "remembers and returns the configuration" do
        expect(htp.configure(get_config)).to eql get_config
      end
    end

    context "Given invalid configuration" do
      context "missing a required keyword" do
        it "raise a ConfigurationValidation::MissingKeywordError" do
          expect{htp.configure(missing_key_config)}.to raise_error ConfigurationValidation::MissingKeywordError
        end
      end

      context "with a invalid keyword" do
        it "raises a ConfigurationValidation::ValueError" do
          expect{htp.configure(invalid_key_config)}.to raise_error ConfigurationValidation::InvalidKeywordError
        end
      end

      context "with a invalid value" do
        it "raises a ConfigurationValidation::ValueError" do
          expect{htp.configure(invalid_value_config)}.to raise_error ConfigurationValidation::InvalidValueError
        end
      end

      it "Allow Basic auth given credentials options" do
        htp.configure(get_config_with_credentials)

        stub_request(:post, "http://localhost:3000").
        with(:headers => {'Authorization'=>'Basic dXNlcjpzZWNyZXQ='}).
        to_return(:status => 200, :body => "", :headers => {})

        htp.send_message(uri, message_with_body)
      end
    end
  end

  context "#send_message" do
    context "Support sending message using different HTTP verbs" do
      it "GET without parameters" do
        htp.configure(get_config)
        stub_request(:get, uri)
        htp.send_message(uri, message)
      end

      it "GET with parameters" do
        htp.configure(get_config)
        stub_request(:get, "http://localhost:3000/?id=1&search=test_search_value")
        htp.send_message(uri, message_with_body)
      end

      it "POST" do
        htp.configure(post_config)
        stub_request(:post, "http://localhost:3000/").with(:body => {"id"=>"1", "search" => "test_search_value"})
        htp.send_message(uri, message_with_body)
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

    it "Allows Https connections" do
      https_uri = "https://example.com"
      htp.configure(get_config)

      stub_request(:get, https_uri)
      htp.send_message(https_uri, message)
    end

    context "When a message was sent" do
      it "return 'Delivered successfull'" do
        htp.configure(get_config)

        stub_request(:get, "http://localhost:3000/").to_return(:status => 200, :body => "", :headers => {})

        expect(htp.send_message(uri, message)).to eql 'Delivered successful'
      end

      it "return 'Delivery failure'" do
        htp.configure(get_config)
        stub_request(:get, "http://localhost:3000/").to_return(:status => 500, :body => "", :headers => {})

        expect(htp.send_message(uri, message)).to eql 'Delivery failure'
      end

      it "return 'Delivery timeout'" do
        htp.configure(get_config)
        stub_request(:get, "http://localhost:3000/").to_return(:status => 408, :body => "", :headers => {})

        expect(htp.send_message(uri, message)).to eql 'Delivery timeout'
      end

      it "return 'Delivery rejected'" do
        htp.configure(get_config)
         stub_request(:get, "http://localhost:3000/").to_return(:status => 401, :body => "", :headers => {})

        expect(htp.send_message(uri, message)).to eql 'Rejected for delivery'
      end

      it "return 'Delivery pending'" do
        htp.configure(get_config)
         stub_request(:get, "http://localhost:3000/").to_return(:status => 508, :body => "", :headers => {})

        expect(htp.send_message(uri, message)).to eql 'Delivery pending'
      end

      it "return 'Unkown delivery status'" do
        htp.configure(get_config)
        stub_request(:get, "http://localhost:3000/").to_return(:status => 208, :body => "", :headers => {})
        expect(htp.send_message(uri, message)).to eql 'Delivery status unkown'
      end

      it "return 'Delivery status unsupported'" do
        htp.configure(get_config)
        stub_request(:get, "http://localhost:3000/").to_return(:status => 1111, :body => "", :headers => {})
        expect(htp.send_message(uri, message)).to eql 'Delivery status unsupported'
      end
    end

    it "Given an invalid URI raise an error" do
      expect{htp.send_message({}, message)}.to raise_error URI::InvalidURIError
    end

    it "Given a invalid message raise an error" do
      pending('Todo')
      htp.configure(get_config)
      expect{htp.send_message(uri, message)}.to raise_error StandardError
    end
  end

  context "#receive_message" do
    context "Given a message was sent successfully" do
      it "return the reponse of the last message sent" do
        htp.configure(get_config)
        stub_request(:get, "http://localhost:3000/").to_return(:status => 200, :body => "Response body", :headers => {})

        htp.send_message(uri, message)
        expect(htp.receive_message).to eql "Response body"
      end
    end
  end
end
