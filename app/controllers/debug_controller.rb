class Stringer < Sinatra::Base
  get "/debug" do
    erb :"debug", locals: { queued_jobs_count: Delayed::Job.count }
  end
end
