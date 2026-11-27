# frozen_string_literal: true

class Views::Profiles::Edit < Views::Base
  attr_accessor :user

  def initialize(user:)
    super()
    self.user = user
  end

  def page_title = t("page_titles.edit_profile")

  def view_template
    h1 { t("profiles.edit.title") }

    stories_feed_form
    username_form
    password_form
  end

  private

  def stories_feed_form
    form_with(model: user, url: profile_path) do |form|
      fieldset do
        legend { t("profiles.edit.stories_feed_settings") }
        spaced { form.label(:stories_order) }
        spaced { form.select(:stories_order, stories_order_options) }
        spaced { form.label(:group_stories) }
        spaced { form.check_box(:group_stories) }
      end
      form.submit("Update")
    end
  end

  def username_form
    form_with(model: user, url: profile_path) do |form|
      fieldset do
        legend { t("profiles.edit.change_username") }
        div(class: "warning") { p { raw(t("profiles.edit.warning_html")) } }
        spaced { form.label(:username) }
        spaced { form.text_field(:username, required: true) }
        password_field(form, :password_challenge, "Existing password")
      end
      form.submit("Update username")
    end
  end

  def password_form
    form_with(model: user, url: password_path) do |form|
      fieldset do
        legend { t("profiles.edit.change_password") }
        password_field(form, :password_challenge, "Existing password")
        password_field(form, :password, "New password")
        password_field(form, :password_confirmation)
      end
      form.submit("Update password")
    end
  end

  def password_field(form, field, label = nil)
    spaced { form.label(field, label) }
    spaced { form.password_field(field, required: true) }
  end

  def spaced
    yield
    whitespace
  end

  def stories_order_options
    User.stories_orders.transform_keys do |key|
      User.human_attribute_name("stories_order.#{key}")
    end
  end
end
