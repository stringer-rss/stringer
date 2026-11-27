# frozen_string_literal: true

class Views::Base < Components::Base
  SITE_NAME = "stringer"

  def around_template
    render(Views::Layouts::Application.new(document_title:)) { super }
  end

  # The page's own name, shown before the site name in the browser title.
  # Every view must define one.
  def page_title
    raise(NotImplementedError, "#{self.class} must define #page_title")
  end

  # Views with a story list override this so the title starts with the
  # unread count, e.g. "(3) Stories | stringer".
  def unread_count = 0

  private

  def site_title
    "#{page_title} | #{SITE_NAME}"
  end

  def document_title
    return site_title unless unread_count.positive?

    "(#{unread_count}) #{site_title}"
  end
end
