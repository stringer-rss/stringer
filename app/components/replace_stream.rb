# frozen_string_literal: true

# A Turbo Stream response that replaces elements by id. `replacements` maps
# each target id to the component to render in its place.
class Components::ReplaceStream < Components::Base
  register_element :turbo_stream

  attr_accessor :replacements

  def initialize(replacements)
    super()
    self.replacements = replacements
  end

  def view_template
    replacements.each do |target, component|
      turbo_stream(action: "replace", target:) do
        template { render(component) }
      end
    end
  end
end
