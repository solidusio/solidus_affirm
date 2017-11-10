source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')

gem 'solidus', github: 'solidusio/solidus', branch: branch

gem 'mysql2'
gem 'pg'

group :development, :test do
  gem "pry-rails"
end

group :test do
  if branch == 'v1.4'
   gem 'rails_test_params_backport', group: :test
  end
end

gemspec
