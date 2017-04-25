require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'byebug'

Capybara.default_driver = :selenium

Capybara.save_path = File.expand_path('../screenshots', __dir__)

RSpec.configure do |config|
  config.disable_monkey_patching!
end

require_relative 'helpers/step_helper'
require_relative 'helpers/retry_helper'
require_relative 'lib/mailtrap'
