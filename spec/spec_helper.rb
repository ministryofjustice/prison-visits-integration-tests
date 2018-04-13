require 'bundler/setup'
Bundler.setup(:default, :development)
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'pry'

Capybara.default_driver = :selenium
Capybara.save_path = File.expand_path('../screenshots', __dir__)
Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.before(:all) do
    check_firefox_version
    page.driver.browser.manage.window.maximize
  end
end

def check_firefox_version
  session = Capybara.current_session
  driver = session.driver
  version = driver.browser.capabilities.version
  version_minor = version.split('.').take(2).join('.').to_f
  err = "Firefox is the incorrect version! Current: #{version_minor}. Expected: 57.0.X"
  raise err if version_minor > 57.0
end

require_relative 'helpers/google_analytics_helper'
require_relative 'helpers/step_helper'
require_relative 'helpers/retry_helper'
require_relative 'lib/mailtrap'
require_relative 'lib/google_analytics'
