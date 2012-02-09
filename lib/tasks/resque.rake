require 'resque/tasks'

task "resque:setup" => :environment do
  require 'resque'
  require 'resque_scheduler'
  require 'resque/scheduler'
  
  ENV['QUEUE'] = '*'

  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
  Resque.schedule = YAML.load_file('config/scheduled_tasks.yml')
end