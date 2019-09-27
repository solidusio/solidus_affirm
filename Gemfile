source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')

gem 'solidus', github: 'solidusio/solidus', branch: branch

if ENV['DB'] == 'mysql'
  gem 'mysql2'
else
  gem 'pg', '~> 1.1'
end

# Needed to help Bundler figure out how to resolve dependencies, otherwise it takes forever to
# resolve them
if branch == 'master' || Gem::Version.new(branch[1..-1]) >= Gem::Version.new('2.10.0')
  gem 'rails', '~> 6.0'
else
  gem 'rails', '~> 5.0'
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
