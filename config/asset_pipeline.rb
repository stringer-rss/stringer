module AssetPipeline
  def registered(app)
    app.set :sprockets, Sprockets::Environment.new(app.root)

    app.get "/assets/*" do
      env["PATH_INFO"].sub!(%r{^/assets}, "")
      settings.sprockets.call(env)
    end

    append_paths(app)
    configure_development(app)
    configure_production(app)
    register_helpers(app)
  end

  private

  def append_paths(app)
    app.sprockets.append_path File.join(app.root, "app", "assets")
    app.sprockets.append_path File.join(app.root, "app", "assets", "stylesheets")
    app.sprockets.append_path File.join(app.root, "app", "assets", "javascripts")
  end

  def configure_development(app)
    app.configure :development do
      app.sprockets.cache = Sprockets::Cache::FileStore.new("./tmp")
    end
  end

  def configure_production(app)
    app.configure :production do
      app.sprockets.css_compressor = :scss
      app.sprockets.js_compressor = :uglify
    end
  end

  def register_helpers(app)
    Sprockets::Helpers.configure do |config|
      config.environment = app.sprockets
      config.prefix = "/assets"
      config.debug = true if app.development?
      config.digest = true if app.production?
    end

    app.helpers Sprockets::Helpers
  end

  module_function :registered,
                  :append_paths,
                  :configure_development,
                  :configure_production,
                  :register_helpers
end
