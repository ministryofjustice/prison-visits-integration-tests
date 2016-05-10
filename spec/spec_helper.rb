require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.current_driver = :poltergeist

module SuppressJsConsoleLogging; end
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new \
    app, phantomjs_logger: SuppressJsConsoleLogging
end

require_relative 'helpers/step_helper'
require_relative 'helpers/retry_helper'
require_relative 'lib/mailtrap'
