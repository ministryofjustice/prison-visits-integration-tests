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
    check_firefox_version
    page.driver.browser.manage.window.resize_to(1920, 1080)
  end
end

def check_firefox_version
  session = Capybara.current_session
  driver = session.driver
  version = driver.browser.capabilities.version
  version_minor = version.split('.').take(2).join('.').to_f
  puts firefox_warning(version_minor) if version_minor > 57.0
end

def firefox_warning(version)
  <<-HEREDOC
    Warning! Capybara is testing against Firefox version: #{version}.
    Capybara may experience problems clicking buttons for any version greater than 57.0.X
  HEREDOC
end

require_relative 'helpers/google_analytics_helper'
require_relative 'helpers/step_helper'
require_relative 'helpers/retry_helper'
require_relative 'lib/mailtrap'
require_relative 'lib/google_analytics'
