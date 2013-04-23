require_relative "../commands/feeds/import_from_opml"
require_relative "../commands/users/create_user"
require_relative "../repositories/user_repository"

class Stringer < Sinatra::Base
  before /\/(password|import)/ do
    if first_run_completed?
      redirect to("/news")
    end
  end

  get "/" do
    redirect to("/password")
  end

  get "/password" do
    erb :"first_run/password"
  end

  post "/password" do
    if no_password(params) or password_mismatch?(params)
      flash.now[:error] = "Hey, your password confirmation didn't match. Try again."
      erb :"first_run/password"
    else
      CreateUser.new.create(params[:password])

      redirect to("/import")
    end
  end

  get "/import" do
    erb :import
  end

  post "/import" do
    ImportFromOpml.import(params["opml_file"][:tempfile].read, true)

    redirect to("/")
  end

  private
  def first_run_completed?
    UserRepository.any?
  end

  def no_password(params)
    params[:password].nil? || params[:password] == ""
  end

  def password_mismatch?(params)
    params[:password] != params[:password_confirmation]
  end
end