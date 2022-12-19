require "spec_helper"

app_require "helpers/authentication_helpers"

RSpec.describe Sinatra::AuthenticationHelpers do
  let(:helper) do
    helper_class = Class.new { include Sinatra::AuthenticationHelpers }
    helper_class.new
  end

  describe "#needs_authentication?" do
    let(:authenticated_path) { "/news" }

    before do
      allow(UserRepository).to receive(:setup_complete?).and_return(true)
    end

    context "when setup in not complete" do
      it "returns false" do
        allow(UserRepository).to receive(:setup_complete?).and_return(false)

        expect(helper.needs_authentication?(authenticated_path)).to be(false)
      end
    end

    %w(/login /logout /heroku).each do |path|
      context "when `path` is '#{path}'" do
        it "returns false" do
          expect(helper.needs_authentication?(path)).to be(false)
        end
      end
    end

    %w(css js img).each do |path|
      context "when `path` contains '#{path}'" do
        it "returns false" do
          expect(helper.needs_authentication?("/#{path}/file.ext")).to be(false)
        end
      end
    end

    context "otherwise" do
      it "returns true" do
        expect(helper.needs_authentication?(authenticated_path)).to be(true)
      end
    end
  end
end
