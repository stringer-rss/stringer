require "spec_helper"

app_require "controllers/languages_controller"

describe "LanguagesController" do
  describe "GET /languages/:lang" do
    it "changes default language to english" do
      get "/languages/en"

      session[:lang].should eq 'en'
    end

    it "changes language and change i18n.locale" do
      get "languages/pt-BR"

      session[:lang].should eq "pt-BR"
      I18n.locale.to_s.should eq "pt-BR"
    end
  end
end
