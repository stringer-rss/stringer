# frozen_string_literal: true

class Components::Footer < Components::Base
  def view_template
    div(class: "container") do
      div(class: "row") do
        div(class: "col-md-8") { links }
        div(class: "col-md-4") { back_to_work }
      end
    end
  end

  private

  def links
    ul(class: "footer-links") do
      user_links if current_user
      li { a(href: "https://github.com/stringer-rss/stringer") { support } }
    end
  end

  def user_links
    link_item("/logout", t("layout.logout"))
    link_item("/feeds/import", t("layout.import"))
    link_item("/feeds/export", t("layout.export"))
    shortcuts_link
    link_item(account_path, t("layout.account"))
    link_item(settings_path, t("layout.admin_settings")) if current_user.admin?
  end

  def link_item(href, text)
    li { a(href:) { text } }
    separator
  end

  def shortcuts_link
    li do
      a(
        href: "#shortcuts",
        data: { bs_toggle: "modal", bs_target: "#shortcuts" },
        aria_label: "shortcuts"
      ) { i(aria_hidden: "true", class: "fa fa-keyboard-o") }
    end
    separator
  end

  def separator
    li(class: "text-muted") { "·" }
  end

  def support
    t("layout.support")
  end

  def back_to_work
    p(class: "float-end") do
      b { t("layout.hey") }
      plain(" #{t('layout.back_to_work')}")
    end
  end
end
