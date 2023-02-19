# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

session_config = { key: "_stringer_session", expire_after: 2.weeks }
Rails.application.config.session_store(:cookie_store, **session_config)
