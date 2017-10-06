require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'byebug'

Capybara.default_driver = :selenium

Capybara.save_path = File.expand_path('../screenshots', __dir__)
Capybara.default_max_wait_time = 10
RSpec.configure do |config|
  config.disable_monkey_patching!
  config.before(:all) do
    # page.driver.browser.manage.window.resize_to(1900, 1200)
  end
end

require_relative 'helpers/google_analytics_helper'
require_relative 'helpers/step_helper'
require_relative 'helpers/retry_helper'
require_relative 'lib/mailtrap'
require_relative 'lib/google_analytics'
