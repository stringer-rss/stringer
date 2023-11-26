# frozen_string_literal: true

require "axe-rspec"

module AccessibilityOverrides
  A11Y_SKIP = [
    "aria-required-children",
    "color-contrast",
    "html-has-lang",
    "label-title-only",
    "landmark-one-main",
    "link-name",
    "page-has-heading-one",
    "region"
  ].freeze

  PATH_SKIP = ["/admin/good_job/jobs", "/test"].freeze

  def visit(*, accessible: true, a11y_skip: A11Y_SKIP)
    page.visit(*)
    accessible = false if PATH_SKIP.include?(page.current_path)
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
      puts(page.current_path)
      expect(page).to have_css("div")
      expect(page).to be_axe_clean.skipping(*a11y_skip)
    end
  end
end

RSpec.configure do |config|
  config.include(AccessibilityOverrides, type: :system)
end
