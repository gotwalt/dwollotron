source "http://rubygems.org"

# Core
gem 'rails'
gem 'yajl-ruby'

# Data
gem 'pg'
gem 'redis'

# Tasks
gem 'resque'

# Remote data
gem 'typhoeus'

# Deploy
gem 'heroku'

# Heroku needs
group :production do
  gem 'thin'
end

# Misc
gem "git_remote_branch"
gem "git-up"

group :development do
  gem 'rspec'
end
  
group :test do
  gem 'capybara'
  gem 'rspec-rails'
  gem 'localtunnel'
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "ZenTest", "4.6.0"
  gem "autotest-growl"
  gem "autotest-fsevent"
  gem 'simplecov', :require => false
  gem 'timecop'
end
