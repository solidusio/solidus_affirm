source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')

gem 'solidus', github: 'solidusio/solidus', branch: branch

if branch == 'master' || branch >= "v2.0"
  gem "rails-controller-testing", group: :test
else
  gem "rails_test_params_backport", group: :test
end

gem 'mysql2'
gem 'pg', '~> 0.21'

group :development, :test do
  gem "pry-rails"
end

group :test do
  if branch == 'v1.4'
   gem 'rails_test_params_backport', group: :test
  end
end

gemspec
