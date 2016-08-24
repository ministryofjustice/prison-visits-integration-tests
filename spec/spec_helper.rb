require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'

Capybara.default_driver = :poltergeist

# This results in a depreciated warning, however it's required for now
# https://github.com/mattheworiordan/capybara-screenshot/issues/170
Capybara.save_and_open_page_path = File.expand_path('../screenshots', __dir__)

module SuppressJsConsoleLogging; end
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new \
    app, phantomjs_logger: SuppressJsConsoleLogging, js_errors: false
end

RSpec.configure do |config|
  config.disable_monkey_patching!
end

require_relative 'helpers/step_helper'
require_relative 'helpers/retry_helper'
require_relative 'lib/mailtrap'
