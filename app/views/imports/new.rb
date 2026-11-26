# frozen_string_literal: true

class Views::Imports::New < Views::Base
  include Phlex::Rails::Helpers::SubmitTag

  def view_template
    nav do
      div do
        plain("Logged in as ")
        link_to(current_user.username, edit_profile_path)
      end
    end

    div(class: "setup", id: "feed-setup") do
      heading
      import_form
    end
  end

  private

  def heading
    h1 { t("import.title") }
    h2 { t("import.subtitle") }
    hr
    p { t("import.description") }
    hr
  end

  def import_form
    form_with(url: "/feeds/import", id: "import", multipart: true) do
      file_input
      whitespace
      submit_tag(t("import.fields.import"), class: "btn btn-primary")
      a(href: "/setup/tutorial", id: "skip", class: "btn float-end") do
        t("import.fields.not_now")
      end
    end
  end

  def file_input
    choose_file = t("import.fields.choose_file")
    input(
      id: "opml_file",
      name: "opml_file",
      type: "file",
      title: choose_file,
      aria_label: choose_file,
      required: true
    )
  end
end
