web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
full_worker: bundle exec rake cleanup_old_stories; while true; do bundle exec rake lazy_fetch; sleep 600; done & while true; do bundle exec rake work_jobs; sleep 60; done
delayed_worker: while true; do bundle exec rake work_jobs; sleep 60; done
console: bundle exec racksh
