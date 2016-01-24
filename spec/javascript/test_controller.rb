class Stringer < Sinatra::Base
  def self.test_path(*chunks)
    File.expand_path(File.join("..", *chunks), __FILE__)
  end

  get "/test" do
    erb File.read(self.class.test_path("support", "views", "index.erb")), layout: false, locals: {
      js_files: js_files,
      js_templates: js_templates
    }
  end

  get "/spec/*" do
    send_file self.class.test_path("spec", *params[:splat])
  end

  get "/vendor/*" do
    send_file self.class.test_path("support", "vendor", *params[:splat])
  end

  private

  def vendor_js_files
    %w(mocha.js sinon.js chai.js chai-changes.js chai-backbone.js sinon-chai.js).map do |name|
      File.join "vendor", "js", name
    end
  end

  def vendor_css_files
    %w(mocha.css).map do |name|
      File.join "vendor", "css", name
    end
  end

  def js_helper_files
    %w(spec_helper.js).map do |name|
      File.join "spec", name
    end
  end

  def js_lib_files
    base = self.class.test_path("..", "..", "app", "public")
    Dir[File.join(base, "js", "**", "*.js")].map do |lib_file|
      lib_file.sub!(base, "")
    end
  end

  def js_test_files
    base = self.class.test_path
    Dir[File.join(base, "**", "*_spec.js")].map do |spec_file|
      spec_file.sub!(base, "")
    end
  end

  def js_files
    vendor_js_files + js_helper_files + js_test_files
  end

  def css_files
    vendor_css_files
  end

  def js_templates
    [:story]
  end
end
