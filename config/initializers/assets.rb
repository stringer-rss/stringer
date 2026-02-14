# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
Rails.application.config.assets.paths += [
  Rails.root.join("node_modules/backbone"),
  Rails.root.join("node_modules/bootstrap/dist/js"),
  Rails.root.join("node_modules/bootstrap/dist/css"),
  Rails.root.join("node_modules/jquery"),
  Rails.root.join("node_modules/mousetrap"),
  Rails.root.join("node_modules/underscore"),
  Rails.root.join("node_modules/jquery-visible")
]
