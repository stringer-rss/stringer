# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  def view_template
    div(class: "setup", id: "feed-setup") do
      heading
      hr
      login_form
      sign_up_link
    end
  end

  private

  def heading
    h1 do
      plain("#{t('sessions.new.title')} ")
      span(class: "orange") { t("sessions.new.rss") }
      plain(".")
    end
    h2 { t("sessions.new.subtitle") }
  end

  def login_form
    form_with(url: "/login") do |form|
      p { raw(t("sessions.new.fields.unknown_username_html")) }
      username_field(form)
      password_field(form)
      input(
        type: "submit",
        value: t("sessions.new.fields.submit"),
        class: "btn btn-primary float-end"
      )
    end
  end

  def username_field(form)
    div do
      form.text_field(:username, class: "form-control", required: true)
      label_text = t("sessions.new.fields.username")
      form.label(:username, label_text, class: "field-label")
    end
  end

  def password_field(form)
    div do
      form.password_field(:password, class: "form-control", required: true)
      i(class: "fa fa-lock field-icon")
      label_text = t("sessions.new.fields.password")
      label_attrs = { id: "password-label", class: "field-label" }
      form.label(:password, label_text, **label_attrs)
    end
  end

  def sign_up_link
    return unless Setting::UserSignup.enabled?

    div { raw(t("sessions.new.sign_up_html", href: setup_password_path)) }
  end
end
