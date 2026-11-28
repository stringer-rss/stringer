# frozen_string_literal: true

# The contents of a story, wrapped in a Turbo Frame. The refresh button
# submits inside the frame, and the refresh action responds with this
# component so Turbo swaps in the updated story.
class Components::StoryFrame < Components::Base
  include Phlex::Rails::Helpers::Sanitize

  register_element :turbo_frame

  # Titles and bodies are cleaned by ContentSanitizer (Loofah) when stored.
  # Rendering cleans them again with the same allowlist, so feed markup like
  # tables, figures and video survives.
  SAFE_LIST = {
    tags: Loofah::HTML5::SafeList::ALLOWED_ELEMENTS,
    attributes: Loofah::HTML5::SafeList::ALLOWED_ATTRIBUTES
  }.freeze

  attr_accessor :story

  def initialize(story:)
    super()
    self.story = story
  end

  def view_template
    turbo_frame(id: "story_#{story.id}") do
      preview
      div(class: "story-body-container") do
        story_body
        render(Components::StoryActions.new(story:))
      end
    end
  end

  private

  def preview
    data = { action: "click->story#previewClicked" }
    div(class: "row story-preview", data:) do
      div(class: "col-md-3") do
        render(Components::StoryStar.new(story:, placement: :preview))
        p(class: "blog-title") { story.source }
      end
      div(class: "col-md-9") { details }
    end
  end

  def details
    p(class: "story-details") do
      span(class: "story-title") { story.headline }
      span(class: "story-lead") { "— #{story.lead}" }
    end
  end

  def story_body
    div(class: "story-body") do
      h1 do
        a(href: story.permalink) { stored_html(story.title) }
        enclosure_link
      end
      div(class: "story-content") { stored_html(story.body) }
    end
  end

  def enclosure_link
    return unless story.enclosure_url

    a(class: "story-enclosure", target: "_blank", href: story.enclosure_url) do
      i(class: "fa fa-download")
    end
  end

  # Returns safe HTML, which Phlex outputs as is when it is a block's content.
  def stored_html(html)
    sanitize(html, **SAFE_LIST)
  end
end
