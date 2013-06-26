class Stringer < Sinatra::Base
  get "/debug" do
    
    erb :"debug"
  end
end
