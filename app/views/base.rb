# frozen_string_literal: true

class Views::Base < Components::Base
  def around_template
    render(Views::Layouts::Application.new(page_title:)) { super }
  end

  # Text shown before the site name in the browser title.
  def page_title = nil
end
