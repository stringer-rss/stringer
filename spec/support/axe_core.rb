# frozen_string_literal: true

require "axe-rspec"

module AccessibilityOverrides
  A11Y_SKIP = [
    "aria-required-children",
    "color-contrast",
    "landmark-one-main",
    "page-has-heading-one",
    "region"
  ].freeze

  def visit(*, accessible: true, a11y_skip: A11Y_SKIP)
    page.visit(*)

    yield if block_given?

    check_accessibility(a11y_skip:) if accessible
  end

  def click_on(*, a11y_skip: A11Y_SKIP, **)
    page.click_on(*, **)

    yield if block_given?

    check_accessibility(a11y_skip:)
  end

  def check_accessibility(a11y_skip:)
    within_window(current_window) do
      expect(page).to have_css("div")
      expect(page).to be_axe_clean.skipping(*a11y_skip)
    end
  end
end

RSpec.configure do |config|
  config.include(AccessibilityOverrides, type: :system)

  # axe-core-api shrinks the Selenium page_load timeout to 1s while it runs
  # (lib/axe/api/run.rb), which intermittently fails under CI load with
  # "Navigation timed out after 1000 ms". Neutralize the setter so it can't.
  # https://github.com/dequelabs/axe-core-gems/issues/386
  config.before(:each, type: :system) do
    page.driver.browser.manage.timeouts.instance_eval do
      def page_load=(*); end
    end
  end
end
