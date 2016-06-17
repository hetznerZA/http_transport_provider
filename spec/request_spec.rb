require 'spec_helper'

describe Request do
  let(:uri) { URI::parse("http://localhost:3000/search") }
  let(:get_config) { {'verb' => 'GET'} }
  let(:post_config) { {'verb' => 'POST'} }
  let(:message_body) { {'id' => '1', 'name' => 'test'} }

  describe "#build" do
    context "Given an URI, configuration and params" do
      context "build the correct request method" do
        it "GET without parameters" do
          request = Request.build(uri, get_config)

          expect(request.method).to eql 'GET'
          expect(request.path).to eql '/search'
        end

        it "GET with parameters" do
          request = Request.build(uri, get_config, message_body)
          expect(request.method).to eql 'GET'
          expect(request.path).to eql '/search?id=1&name=test'
        end

        it "POST without body" do
          request = Request.build(uri, post_config)
          expect(request.method).to eql 'POST'
          expect(request.body).to eql nil
        end

        it "POST with body" do
          request = Request.build(uri, post_config, message_body)
          expect(request.method).to eql 'POST'
          expect(request.body).to eql 'id=1&name=test'
        end

        context "Configure request with Basic Auth" do
          context "Given valid credentials" do
            it "set the authorization header" do
              config = { 'verb' => 'GET', 'credentials' => {'username' => 'user', 'password' => 'secret'}}
              request = Request.build(uri, config)

              expect(request.method).to eql 'GET'
              expect(request.get_fields 'authorization').to eql ["Basic dXNlcjpzZWNyZXQ="]
            end
          end

          context "Given no credentials" do
            it "don't set the the authorization header" do
              config = {'verb' => 'POST'}
              request = Request.build(uri, config)

              expect(request.method).to eql 'POST'
              expect(request.get_fields 'authorization').not_to eql ["Basic dXNlcjpzZWNyZXQ="]
            end
          end
        end
      end
    end
  end
end
