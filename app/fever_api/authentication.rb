module FeverAPI
  class Authentication
    def call(params)
      { auth: 1, last_refreshed_on_time: Time.now.to_i }
    end
  end
end
