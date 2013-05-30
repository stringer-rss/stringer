require_relative "../commands/superfeedr/setup_superfeedr"

class Stringer < Sinatra::Base

  namespace "/setup" do
    get "/superfeedr" do
      @user = UserRepository.fetch(session[:user_id])
      erb :"first_run/superfeedr"
    end
    post "/superfeedr" do
      @host = request.host
      @username = params[:superfeedr_username]
      @password = params[:superfeedr_password]

      superfeedr = SetupSuperfeedr.add(@host, @username, @password)

      if superfeedr
        require_relative "../tasks/initialize_superfeedr"

        flash[:success] = t('superfeedr.add.flash.connected')
        redirect to("/")

      else
        flash.now[:error] = t('superfeedr.add.flash.not_connected')
        redirect to("/setup/superfeedr")
      end
    end
  end

  post "/delete/superfeedr" do
    @username = params[:remove_superfeedr_username]
    superfeedr = SetupSuperfeedr.remove(@username)
    if superfeedr
      flash[:success] = t('superfeedr.remove.flash.disconnected')
      redirect to("/")
    else
      flash[:error] = t('superfeedr.remove.flash.not_disconnected')
      redirect to("/setup/superfeedr")  
    end
  end
  
end
