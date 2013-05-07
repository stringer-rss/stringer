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
    end
  end
end
