require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'
require 'capybara-webkit'

Capybara.default_driver = :webkit

Capybara.save_path = File.expand_path('../screenshots', __dir__)

RSpec.configure do |config|
  config.disable_monkey_patching!
end

require_relative 'helpers/step_helper'
require_relative 'helpers/retry_helper'
require_relative 'lib/mailtrap'
