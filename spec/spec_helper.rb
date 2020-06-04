require 'bundler/setup'
Bundler.setup(:default, :development)
require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.default_driver = :selenium
Capybara.save_path = File.expand_path('../screenshots', __dir__)
Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.before(:all) do
    page.driver.browser.manage.window.resize_to(1920, 1080)
    # prevent mailtrap inbox from filling up
    Mailtrap.instance.clean_if_full
  end
end

require_relative 'helpers/google_analytics_helper'
require_relative 'helpers/step_helper'
require_relative 'helpers/retry_helper'
require_relative 'lib/mailtrap'
require_relative 'lib/google_analytics'
require_relative 'lib/mailtrap_email'
