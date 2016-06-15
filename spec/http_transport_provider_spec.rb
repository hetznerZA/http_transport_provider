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

  context "#send_message" do
    context "Support different HTTP verbs" do
      it "GET without parameters" do
        message = {'options' => {'http_verb' => 'GET'}}

        stub_request(:get, uri)
        htp.send_message(uri, message)
      end

      it "GET with parameters" do
        message = {'body' => {'search' => 'test_search_value', 'id' => '1'}, 'options' => {'http_verb' => 'GET'}}

        stub_request(:get, "http://localhost:3000/?id=1&search=test_search_value")
        htp.send_message(uri, message)
      end

      it "POST" do
        message = { 'body' => {'id' => 1}, 'options' => {'http_verb' => 'POST'} }

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

    it "Allow Basic auth given credentials options" do
      message = {'options' => {'http_verb' => 'GET'},
                 'credentials' => {'username' => 'user', 'password' => 'secret'}}

      stub_request(:get, "http://localhost:3000/").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic dXNlcjpzZWNyZXQ=', 'Host'=>'localhost:3000', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "", :headers => {})
      htp.send_message(uri, message)
    end

    it "Allows Https connections" do
      https_uri = "https://example.com"
      message = {'options' => {'http_verb' => 'GET'}}

      stub_request(:get, "https://example.com")
      htp.send_message(https_uri, message)
    end

    context "When a message was sent" do
      it "return 'Delivered successfull'" do
        message = {'options' => {'http_verb' => 'GET'}}
        stub_request(:get, "http://localhost:3000/").to_return(:status => 200, :body => "", :headers => {})

        #TODO: Bump soar_transport_api version to fix spelling mistake
        expect(htp.send_message(uri, message)).to eql 'Delivered successfull'
      end

      it "return 'Delivered failure'" do
        message = {'options' => {'http_verb' => 'GET'}}
        stub_request(:get, "http://localhost:3000/").to_return(:status => 500, :body => "", :headers => {})

        expect(htp.send_message(uri, message)).to eql 'Delivery failure'
      end

      it "return 'Delivered timeout'" do
        message = {'options' => {'http_verb' => 'GET'}}
        stub_request(:get, "http://localhost:3000/").to_return(:status => 408, :body => "", :headers => {})

        expect(htp.send_message(uri, message)).to eql 'Delivery timeout'
      end

      it "return 'Delivered rejected'" do
        message = {'options' => {'http_verb' => 'GET'}, "credentials" => {"username" => 'test', "password" => 'secret'}}
        stub_request(:get, "http://localhost:3000/").to_return(:status => 401, :body => "", :headers => {})

        expect(htp.send_message(uri, message)).to eql 'Rejected for delivery'
      end

      it "return 'Delivered pending'" do
        pending
        expect(htp.send_message(uri, message)).to eql 'Delivered pending'
      end

      it "return 'Unkown delivery status'" do
        message = {'options' => {'http_verb' => 'GET'}}
        stub_request(:get, "http://localhost:3000/").to_return(:status => 1111, :body => "", :headers => {})

        expect(htp.send_message(uri, message)).to eql 'Delivery status unkown'
      end
    end

    it "Given an invalid URI raise an error" do
      pending
      expect(false).to eql true
    end

    it "Given a invalid message raise an error" do
      expect{htp.send_message(uri, {'body' => ''})}.to raise_error MessageInvalidError
    end
  end

  context "#receive_message" do
    context "Given a message was sent successfully" do
      it "return the reponse of the last message sent" do
        stub_request(:get, "http://localhost:3000/").to_return(:status => 200, :body => "Response body", :headers => {})

        message = {'options' => {'http_verb' => 'GET'}}
        htp.send_message(uri, message)
        expect(htp.receive_message).to eql "Response body"
      end
    end
  end
end
