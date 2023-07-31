# frozen_string_literal: true

class TestController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    authorization.skip
    prepend_view_path(test_path("support", "views"))
    render(layout: false, locals: { js_files: })
  end

  def spec
    authorization.skip
    send_file(test_path("spec", "#{params[:splat]}.js"))
  end

  def vendor
    authorization.skip

    filename = "#{params[:splat]}.#{params[:format]}"
    send_file(test_path("support", "vendor", params[:format], filename))
  end

  private

  def test_path(*)
    File.expand_path(File.join(__dir__, *))
  end

  def vendor_js_files
    [
      "vendor/js/mocha.js",
      "vendor/js/sinon.js",
      "vendor/js/chai.js",
      "vendor/js/chai-changes.js",
      "vendor/js/chai-backbone.js",
      "vendor/js/sinon-chai.js"
    ]
  end

  def vendor_css_files
    ["vendor/css/mocha.css"]
  end

  def js_helper_files
    ["spec/spec_helper.js"]
  end

  def js_test_files
    ["/spec/models/story_spec.js", "/spec/views/story_view_spec.js"]
  end

  def js_files
    vendor_js_files + js_helper_files + js_test_files
  end

  def css_files
    vendor_css_files
  end
  helper_method :css_files
end
