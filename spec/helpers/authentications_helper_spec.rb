require "spec_helper"

app_require "helpers/authentication_helpers"

RSpec.describe Sinatra::AuthenticationHelpers do
  class Helper
    include Sinatra::AuthenticationHelpers
  end

  let(:helper) { Helper.new }

  describe "#needs_authentication?" do
    let(:authenticated_path) { "/news" }

    before do
      stub_const("ENV", "RACK_ENV" => "not-test")
      allow(UserRepository).to receive(:setup_complete?).and_return(true)
    end

    context "when `RACK_ENV` is 'test'" do
      it "returns false" do
        stub_const("ENV", "RACK_ENV" => "test")

        expect(helper.needs_authentication?(authenticated_path)).to eq(false)
      end
    end

    context "when setup in not complete" do
      it "returns false" do
        allow(UserRepository).to receive(:setup_complete?).and_return(false)

        expect(helper.needs_authentication?(authenticated_path)).to eq(false)
      end
    end

    %w(/login /logout /heroku).each do |path|
      context "when `path` is '#{path}'" do
        it "returns false" do
          expect(helper.needs_authentication?(path)).to eq(false)
        end
      end
    end

    %w(css js img).each do |path|
      context "when `path` contains '#{path}'" do
        it "returns false" do
          expect(helper.needs_authentication?("/#{path}/file.ext")).to eq(false)
        end
      end
    end

    context "otherwise" do
      it "returns true" do
        expect(helper.needs_authentication?(authenticated_path)).to eq(true)
      end
    end
  end
end
