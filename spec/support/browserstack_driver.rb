require "selenium/webdriver"
caps = Selenium::WebDriver::Remote::Capabilities.new
caps["browser"] = "internet explorer"
caps["version"] = "8"
caps["build"] = "First build"
caps["browserstack.debug"] = "true"
caps["javascriptEnabled"] = "true"
caps["platform"] = 'WIN8'

class Capybara::Selenium::Driver < Capybara::Driver::Base
  def reset!
    if @browser
      @browser.navigate.to('about:blank')
    end
  end
end



Capybara.register_driver :browserstack do |app|
  Capybara::Selenium::Driver.new(
    app, browser: :remote,
    url: "http://yannmarquet1:3pRgxdEJNNss9zkUou5X@hub-cloud.browserstack.com/wd/hub",
    desired_capabilities: caps
  )
end
