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
      field(form, :username, t("sessions.new.fields.username"))
      field(form, :password, t("sessions.new.fields.password"), :password)
      input(
        type: "submit",
        value: t("sessions.new.fields.submit"),
        class: "btn btn-primary float-end"
      )
    end
  end

  def field(form, field, label, type = :text)
    render(Components::SetupField.new(form:, field:, label:, type:))
  end

  def sign_up_link
    return unless Setting::UserSignup.enabled?

    div { raw(t("sessions.new.sign_up_html", href: setup_password_path)) }
  end
end
