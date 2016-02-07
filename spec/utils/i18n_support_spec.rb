require "spec_helper"

describe "i18n" do
  before do
    allow(UserRepository).to receive(:setup_complete?).and_return(false)
    ENV["LOCALE"] = locale
    get "/"
  end

  context "when no locale was set" do
    let(:locale) { nil }

    it "should load default locale" do
      expect(I18n.locale.to_s).to eq "en"
      expect(I18n.locale.to_s).not_to eq nil
    end
  end

  context "when locale was set" do
    let(:locale) { "en" }

    it "should load default locale" do
      expect(I18n.locale.to_s).to eq "en"
      expect(I18n.t("layout.title")).to eq "stringer | your rss buddy"
    end
  end

  context "when a missing locale was set" do
    let(:locale) { "xx" }

    it "should not find localization strings" do
      expect(I18n.t("layout.title", locale: ENV["LOCALE"].to_sym)).not_to eq "stringer | your rss buddy"
    end
  end
end
