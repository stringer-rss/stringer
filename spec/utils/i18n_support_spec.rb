# frozen_string_literal: true

describe "i18n", type: :request do
  before do
    allow(UserRepository).to receive(:setup_complete?).and_return(false)
    ENV["LOCALE"] = locale
    get "/"
  end

  context "when no locale was set" do
    let(:locale) { nil }

    it "loads default locale" do
      expect(I18n.locale.to_s).to eq("en")
      expect(I18n.locale.to_s).not_to be_nil
    end
  end

  context "when locale was set" do
    let(:locale) { "en" }

    it "loads default locale" do
      expect(I18n.locale.to_s).to eq("en")
      expect(I18n.t("layout.title")).to eq("stringer | your rss buddy")
    end
  end
end
