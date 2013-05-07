require "spec_helper"

describe "i18n" do
  context "when no locale was set" do
    ENV['locale'] = nil

    it "should load default locale" do
      I18n.locale.to_s.should eq "en"
      I18n.locale.to_s.should_not eq nil
    end
  end

  context "when locale was set" do
    ENV['locale'] = "en"

    it "should load default locale" do
      I18n.locale.to_s.should eq "en"
      I18n.t('layout.title').should eq "stringer | your rss buddy"
    end
  end

  context "when a missing locale was set" do
    ENV['locale'] = "xx"

    it "should not find localization strings" do
      I18n.t('layout.title', locale: ENV['locale'].to_sym).should_not eq "stringer | your rss buddy"
    end
  end
end
