require 'spec_helper'

describe MessageValidation do
  context "Given a valid message" do
    it "return true" do
      message = {'options' => {'http_verb' => 'GET'}}
      expect(MessageValidation::valid?(message)).to eql true
    end
  end

  context "Given an invalid message" do
    it "raise error MessageInvalidError if options eql ''" do
      message = {'options' => ''}
      expect{MessageValidation::valid?(message)}.to raise_error(MessageInvalidError)
    end

    it "raise error MessageInvalidError if options eql {}" do
      message = {'options' => {}}
      expect{MessageValidation::valid?(message)}.to raise_error(MessageInvalidError)
    end

    it "raise error MessageInvalidError if options eql nil" do
      message = {'options' => {}}
      expect{MessageValidation::valid?(message)}.to raise_error(MessageInvalidError)
    end

    it "raise error MessageInvalidError if options['verb'] eql ''" do
      message = {'options' => {'verb' => ''}}
      expect{MessageValidation::valid?(message)}.to raise_error(MessageInvalidError)
    end

    it "raise error MessageInvalidError if options['verb'] eql {}" do
      message = {'options' => {'verb' => ''}}
      expect{MessageValidation::valid?(message)}.to raise_error(MessageInvalidError)
    end

    it "raise error MessageInvalidError if options['verb'] eql nil" do
      message = {'options' => {'verb' => ''}}
      expect{MessageValidation::valid?(message)}.to raise_error(MessageInvalidError)
    end

    it "raise error MessageInvalidError if no options keyword is provided" do
      message = {'body' => ''}
      expect{MessageValidation::valid?(message)}.to raise_error(MessageInvalidError)
    end
  end
end
