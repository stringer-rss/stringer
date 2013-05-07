class Stringer < Sinatra::Base
  get "/languages/:lang" do
    session[:lang] = params[:lang]
    I18n.locale = params[:lang].to_sym

    redirect to("/")
  end
end
