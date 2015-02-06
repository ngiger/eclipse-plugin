source 'https://rubygems.org'

# Specify your gem's dependencies in eclipse-plugin.gemspec
gemspec

group :debuggers do
if /^2/.match(RUBY_VERSION)
  gem 'pry-byebug'
else
  gem 'pry-debugger'
end
end
