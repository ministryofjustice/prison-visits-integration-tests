require "selenium/webdriver"
require 'yaml'
require 'pp'

class Capybara::Selenium::Driver < Capybara::Driver::Base
  def reset!
    if @browser
      @browser.navigate.to('about:blank')
    end
  end
end

TASK_ID = (ENV['TASK_ID'] || 0).to_i
CONFIG_NAME = ENV['CONFIG_NAME'] || 'single'

CONFIG = YAML.load(File.read(File.join(File.dirname(__FILE__), "../../config/#{CONFIG_NAME}.config.yml")))
CONFIG['key'] = ENV['TESTINGBOT_KEY'] || CONFIG['key']
CONFIG['secret'] = ENV['TESTINGBOT_SECRET'] || CONFIG['secret']

pp CONFIG

Capybara.register_driver :testingbot do |app|
  @caps = CONFIG['common_caps'].merge(CONFIG['browser_caps'][TASK_ID])

  Capybara::Selenium::Driver.new(app,
    :browser => :remote,
    :url => "http://#{CONFIG['key']}:#{CONFIG['secret']}@#{CONFIG['server']}/wd/hub",
    :desired_capabilities => @caps
  )
end
