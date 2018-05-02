source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')

gem 'solidus', github: 'solidusio/solidus', branch: branch

gem "rails-controller-testing", group: :test

gem 'mysql2'
gem 'pg', '~> 0.21'

group :development, :test do
  gem "pry-rails"
end

gemspec
