# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add additional assets to the asset load path.
Rails.application.config.assets.paths += [
  Rails.root.join("node_modules/bootstrap/dist/css"),
  Rails.root.join("node_modules/@fontsource/lato/files"),
  Rails.root.join("node_modules/@fontsource/reenie-beanie/files"),
  Rails.root.join("node_modules/font-awesome/css"),
  Rails.root.join("node_modules/font-awesome/fonts")
]
