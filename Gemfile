source 'https://rubygems.org'

# Specify your gem's dependencies in eyemanager.gemspec
gemspec

group :development, :test do
  gem "rb-fsevent", :require => false if RUBY_PLATFORM =~ /darwin/i
  gem "guard-rspec"
end