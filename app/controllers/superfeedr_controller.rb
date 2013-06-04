require_relative "../commands/superfeedr/setup_superfeedr"

class Stringer < Sinatra::Base

  namespace "/config" do
    get "/superfeedr" do
      @user = UserRepository.fetch(session[:user_id])
      erb :"first_run/superfeedr"
    end
    post "/superfeedr" do

      if no_username_password(params)
        flash.now[:error] = t('first_run.superfeedr.flash.no_username_password')
        erb :"first_run/superfeedr"
      else
        @host = request.host
        @username = params[:superfeedr_username]
        @password = params[:superfeedr_password]

        begin
          SetupSuperfeedr.add(@host, @username, @password)
          require_relative "../tasks/initialize_superfeedr"

          flash[:success] = t('superfeedr.add.flash.connected')
          redirect to("/")
        rescue Exception => msg  
          flash.now[:error] = t('superfeedr.add.flash.not_connected')
          redirect to("/")
        end 

      end
    end
  end

  post "/delete/superfeedr" do
    @username = params[:remove_superfeedr_username]
      
    begin
      user = SetupSuperfeedr.remove(@username)
      if user 
        flash[:success] = t('superfeedr.remove.flash.disconnected')
        redirect to("/")
      else
        flash[:error] = t('superfeedr.remove.flash.not_disconnected')
        redirect to("/")
      end
    rescue Exception => msg  
      flash[:error] = t('superfeedr.remove.flash.not_disconnected')
      redirect to("/")
    end 

  end
  
  private
  def no_username_password(params)
    params[:superfeedr_username].nil? || params[:superfeedr_password].nil?
  end

end
