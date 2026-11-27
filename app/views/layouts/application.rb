# frozen_string_literal: true

class Views::Layouts::Application < Components::Base
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::JavascriptIncludeTag
  include Phlex::Rails::Helpers::StylesheetLinkTag

  attr_accessor :document_title

  def initialize(document_title:)
    super()
    self.document_title = document_title
  end

  def view_template(&)
    doctype

    html(lang: I18n.locale) do
      head { head_tags }
      body { page_body(&) }
    end
  end

  private

  def page_body(&)
    div(id: "wrap") do
      div(id: "frame") { frame(&) }
      div(id: "push")
    end
    div(id: "footer") { render(Components::Footer.new) }
  end

  def head_tags
    title { document_title }
    csrf_meta_tags
    meta(charset: "utf-8")
    meta(name: "viewport", content: "width=device-width, initial-scale=1")
    app_icon_tags
    stylesheet_link_tag("application")
    javascript_include_tag("application")
  end

  def app_icon_tags
    link(rel: "shortcut icon", href: "/img/favicon.png")
    link(
      rel: "apple-touch-icon-precomposed",
      href: "/img/apple-touch-icon-precomposed.png"
    )
    link(rel: "manifest", href: "/manifest.json")
    meta(name: "mobile-web-app-capable", content: "yes")
    meta(name: "apple-mobile-web-app-capable", content: "yes")
  end

  def frame(&)
    render(Components::Flash.new)
    render(Components::Shortcuts.new) if current_user
    div(class: "container") do
      div(class: "row") { div(class: "col-md-12", &) }
    end
  end
end
