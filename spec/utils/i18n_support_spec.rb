require "spec_helper"

describe "i18n" do
  before do
    UserRepository.stub(:setup_complete?).and_return(false)
    ENV['LOCALE'] = locale
    get "/"
  end

  context "when no locale was set" do
    let(:locale) { nil }

    it "should load default locale" do
      I18n.locale.to_s.should eq "en"
      I18n.locale.to_s.should_not eq nil
    end
  end

  context "when locale was set" do
    let(:locale) { 'en' }

    it "should load default locale" do
      I18n.locale.to_s.should eq "en"
      I18n.t('layout.title').should eq "stringer | your rss buddy"
    end
  end

  context "when a missing locale was set" do
    let(:locale) { 'xx' }

    it "should not find localization strings" do
      I18n.t('layout.title', locale: ENV['LOCALE'].to_sym).should_not eq "stringer | your rss buddy"
    end
  end
end

