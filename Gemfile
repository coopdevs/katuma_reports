source 'https://rubygems.org'

ruby '2.1.5'

gem 'devise', '2.2.8'
gem 'devise-encryptable', '0.1.2'
gem 'pg', '0.13.2'
gem 'rails', '3.2.22'
gem 'rails-i18n', '~>3.0.0'
gem 'spree', github: 'openfoodfoundation/spree', branch: 'spree-upgrade-step1c'
gem 'figaro', '0.7.0'

gem 'delayed_job_active_record', '4.0.2'
gem 'delayed_job_web', '~> 1.2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'sass-rails',   '~> 3.2.3'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :test do
  gem 'factory_girl_rails', '3.3.0'
  gem 'ffaker', '~> 1.15'
  gem 'rspec-rails', '~> 3.6'
end

group :development, :test do
  gem 'byebug', '~> 9.0'
end

group :production do
  gem 'unicorn', '5.3.0'
end
