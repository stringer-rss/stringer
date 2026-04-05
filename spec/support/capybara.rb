# frozen_string_literal: true

require "capybara/rails"

Capybara.enable_aria_label = true
Capybara.save_path = ENV.fetch("CIRCLE_ARTIFACTS", Capybara.save_path)
Capybara.server = :puma, { Silent: true }

Selenium::WebDriver.logger.output = Rails.root.join("log/selenium.log")

using = ENV.fetch("DRIVER", :firefox).to_sym

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:selenium, using:) do |driver|
      driver.add_preference("browser.download.folderList", 2)
      driver.add_preference("browser.download.manager.showWhenStarting", false)
      driver.add_preference("browser.download.dir", Downloads::PATH.to_s)
      driver.add_preference(
        "browser.helperApps.neverAsk.saveToDisk",
        "application/xml"
      )
    end
  end
end
