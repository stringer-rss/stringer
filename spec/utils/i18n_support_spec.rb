# frozen_string_literal: true

RSpec.describe "i18n", type: :request do
  it "loads default locale when no locale was set" do
    allow(UserRepository).to receive(:setup_complete?).and_return(false)
    ENV["LOCALE"] = nil
    get "/"

    expect(I18n.locale.to_s).to eq("en")
    expect(I18n.locale.to_s).not_to be_nil
  end

  it "loads default locale was locale was set" do
    allow(UserRepository).to receive(:setup_complete?).and_return(false)
    ENV["LOCALE"] = "en"
    get "/"

    expect(I18n.locale.to_s).to eq("en")
    expect(I18n.t("layout.title")).to eq("stringer | your rss buddy")
  end
end
