web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: while true; do bundle exec rake work_jobs; sleep 60; done
console: bundle exec racksh