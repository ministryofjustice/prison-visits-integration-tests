require 'capybara/rspec'
# require 'capybara-screenshot/rspec'
require 'byebug'
require_relative 'support/testingbot_driver'

Capybara.default_driver = :testingbot
Capybara.run_server = false

Capybara.save_path = File.expand_path('../screenshots', __dir__)

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.before(:all) do
    page.driver.browser.manage.window.resize_to(1900, 1200)
  end
end

require_relative 'helpers/step_helper'
require_relative 'helpers/retry_helper'
require_relative 'lib/mailtrap'
