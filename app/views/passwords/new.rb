# frozen_string_literal: true

class Views::Passwords::New < Views::Base
  def page_title = t("page_titles.set_up_account")

  def view_template
    div(class: "setup", id: "password-setup") do
      heading
      hr
      p { t("first_run.password.description") }
      hr
      password_form
    end
  end

  private

  def heading
    h1 do
      plain("#{t('first_run.password.title')} ")
      span(class: "orange") { t("first_run.password.anti_social") }
      plain(".")
    end
    h2 { t("first_run.password.subtitle") }
  end

  def password_form
    url = "/setup/password"
    form_with(model: User.new, url:, id: "password_setup") do |form|
      fields(form)
      submit_button
    end
  end

  def fields(form)
    field(form, :username, t("first_run.password.fields.username"))
    field(form, :password, t("first_run.password.fields.password"), :password)
    confirmation = t("first_run.password.fields.password_confirmation")
    field(form, :password_confirmation, confirmation, :password)
  end

  def field(form, field, label, type = :text)
    render(Components::SetupField.new(form:, field:, label:, type:))
  end

  def submit_button
    input(
      type: "submit",
      id: "submit",
      class: "btn btn-primary float-end",
      value: t("first_run.password.fields.next")
    )
  end
end
