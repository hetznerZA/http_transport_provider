require 'spec_helper'

describe Request do
  let(:uri) { URI::parse("http://localhost:3000/search") }

  describe "#build" do
    it "GET request without parameters" do
      request = Request.build(uri, 'get')

      expect(request.method).to eql 'GET'
      expect(request.path).to eql '/search'
    end

    it "GET request with parameters" do
      params = {'id' => '1', 'name' => 'test'}

      request = Request.build(uri, 'GET', params)
      expect(request.method).to eql 'GET'
      expect(request.path).to eql '/search?id=1&name=test'
    end

    it "POST request with body" do
      params = {'id' => '1', 'name' => 'test'}

      request = Request.build(uri, 'post', params)
      expect(request.method).to eql 'POST'
      expect(request.body).to eql 'id=1&name=test'
    end

    context "Basic Auth" do
      context "Given valid credentials" do
        it "set the authorization header" do
          credentials = {'username' => 'user', 'password' => 'secret'}
          params = {'id' => '1', 'name' => 'test'}

          request = Request.build(uri, 'post', params, credentials)
          expect(request.method).to eql 'POST'
          expect(request.get_fields 'authorization').to eql ["Basic dXNlcjpzZWNyZXQ="]
        end
      end

      context "Given no credentials" do
        it "don't set the the authorization header" do
          params = {'id' => '1', 'name' => 'test'}

          request = Request.build(uri, 'post', params)
          expect(request.method).to eql 'POST'
          expect(request.get_fields 'authorization').not_to eql ["Basic dXNlcjpzZWNyZXQ="]
        end
      end
    end
  end
end
