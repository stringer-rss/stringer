# frozen_string_literal: true

class Views::Settings::Index < Views::Base
  attr_accessor :setting

  def initialize(setting:)
    super()
    self.setting = setting
  end

  def view_template
    div(id: "action-bar") { render(Components::FeedActionBar.new) }

    div(class: "setup") do
      h1 { t("settings.index.heading") }
      hr
      p { t("settings.index.description") }
      hr
      div { signup_form }
    end
  end

  private

  def signup_form
    url = setting_path(setting)
    form_with(model: setting, scope: :setting, url:) do |form|
      if Setting::UserSignup.enabled?
        disable_signups(form)
      else
        enable_signups(form)
      end
    end
  end

  def disable_signups(form)
    form.hidden_field(:enabled, value: false)
    span(class: "setup__label") { t("settings.index.signup.enabled") }
    submit(form, t("settings.index.signup.disable"))
  end

  def enable_signups(form)
    form.hidden_field(:enabled, value: true)
    span(class: "setup__label") { t("settings.index.signup.disabled") }
    submit(form, t("settings.index.signup.enable"))
  end

  def submit(form, text)
    form.submit(text, class: "btn btn-primary float-end")
  end
end
