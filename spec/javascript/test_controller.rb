# frozen_string_literal: true

class Stringer < Sinatra::Base
  def test_path(*chunks)
    File.expand_path(File.join(__dir__, *chunks))
  end

  get "/test" do
    erb File.read(test_path("support", "views", "index.erb")),
        layout: false,
        locals: { js_files: }
  end

  get "/spec/*" do
    send_file test_path("spec", *params[:splat])
  end

  get "/vendor/*" do
    send_file test_path("support", "vendor", *params[:splat])
  end

  private

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
end
