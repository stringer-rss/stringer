# frozen_string_literal: true

# Shown on the stories page when there's nothing left to read.
class Components::Zen < Components::Base
  def view_template
    div(id: "zen") do
      span(id: "zero") { "– 0 –" }
      p { t("partials.zen.rss_zero") }
      p { small { go_make_something } }
      p(class: "view-all") { a(href: "/archive") { t("partials.zen.archive") } }
    end
  end

  private

  def go_make_something
    plain("#{t('partials.zen.gtfo')} ")
    span(id: "gtfo") { t("partials.zen.go_make") }
    plain(".")
  end
end
