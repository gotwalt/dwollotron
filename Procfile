web:    bundle exec thin start -p $PORT
worker: bundle exec rake environment resque:work QUEUE=*
clock:  bundle exec rake environment resque:scheduler