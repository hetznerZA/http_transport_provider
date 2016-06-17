require 'spec_helper'

describe ConfigurationValidation do
  context "Validation" do
    context "Given valid configuration" do
      it "remembers the config" do
        config = {'verb' => "GET"}
        expect(ConfigurationValidation.valid?(config)).to eql true
      end

      it "remembers the config with credentials" do
        config = {'verb' => "GET", 'credentials' => {'username' => 'user', 'password' => 'secret'}}
        expect(ConfigurationValidation.valid?(config)).to eql true
      end
    end

    context "Given a configuration without a verb" do
      it "raises error ConfigurationValidation::MissingKeywordError" do
        config = {'credentials' => {'username' => 'test', 'password' => 'secret'}}
        expect{ConfigurationValidation.valid?(config)}.to raise_error ConfigurationValidation::MissingKeywordError
      end
    end

    context "Given invalid configuration" do
      it "raises error ConfigurationValidation::InvalidValueError" do
        config = {'verb' => 'mymadeupverb'}
        expect{ConfigurationValidation.valid?(config)}.to raise_error ConfigurationValidation::InvalidValueError
      end
    end

    context "Given unsupported key" do
      it "raises error ConfigurationValidation::InvalidKeywordError" do
        config = {'verb' => 'GET', 'unsupported_key' => 'data'}
        expect{ConfigurationValidation.valid?(config)}.to raise_error ConfigurationValidation::InvalidKeywordError
      end
    end
  end
end
