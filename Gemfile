# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(File.expand_path('.ruby-version', __dir__)).strip

gem 'rails', '~> 5.2.1'

# Application dependencies
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bundle-audit'
gem 'chartkick'
gem 'devise'
gem 'faraday-http-cache'
gem 'friendly_id'
gem 'haml-rails'
gem 'mailgun-ruby'
gem 'mixpanel-ruby'
gem 'octokit'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-meetup', git: 'https://github.com/tdooner/omniauth-meetup.git'
gem 'omniauth-salesforce'
gem 'pg'
gem 'puma', '~> 3.12'
gem 'redcarpet'
gem 'redis', '~> 4.0'
gem 'rubyzip'
gem 'sass-rails', '~> 5.0'
gem 'scenic'
gem 'sentry-raven'
gem 'tomlrb'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'
gem 'wisper'
gem 'wisper-activerecord'
gem 'wisper-rspec', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'spring-commands-rspec'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
