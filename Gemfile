# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'rubocop-ast'
gem 'thor'

group :test, :development do
  gem "pry-byebug"
  gem "rbs"
end

group :test do
  gem "rspec"
end
