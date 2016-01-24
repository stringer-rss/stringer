require_relative "../commands/feeds/import_from_opml"
require_relative "../commands/users/create_user"
require_relative "../commands/users/complete_setup"
require_relative "../repositories/user_repository"
require_relative "../repositories/story_repository"
require_relative "../tasks/fetch_feeds"

class Stringer < Sinatra::Base
  namespace "/setup" do
    before do
      redirect to("/news") if UserRepository.setup_complete?
    end

    get "/password" do
      erb :"first_run/password"
    end

    post "/password" do
      if no_password(params) || password_mismatch?(params)
        flash.now[:error] = t("first_run.password.flash.passwords_dont_match")
        erb :"first_run/password"
      else
        user = CreateUser.new.create(params[:password])
        session[:user_id] = user.id

        redirect to("/feeds/import")
      end
    end

    get "/tutorial" do
      FetchFeeds.enqueue(Feed.all)
      CompleteSetup.complete(current_user)

      @sample_stories = StoryRepository.samples
      erb :tutorial
    end
  end

  private

  def no_password(params)
    params[:password].nil? || params[:password] == ""
  end

  def password_mismatch?(params)
    params[:password] != params[:password_confirmation]
  end
end
