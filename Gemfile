source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')

gem 'solidus', github: 'solidusio/solidus', branch: branch

if ENV['DB'] == 'mysql'
  gem 'mysql2'
else
  gem 'pg', '~> 0.21'
end

group :development, :test do
  gem "pry-rails"
end

group :test do
  gem 'solidus_support', github: 'solidusio/solidus_support'

  factory_bot_version = if branch < 'v2.5'
    '4.10.0'
  else
    '> 4.10.0'
  end

  gem 'factory_bot', factory_bot_version
  gem 'rails-controller-testing'
end

gemspec
