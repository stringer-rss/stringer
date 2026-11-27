# frozen_string_literal: true

class Components::IconField < Components::Base
  attr_accessor :input_attrs, :icon, :label_id, :label_text

  def initialize(input:, icon:, label_id:, label_text:)
    super()
    self.input_attrs = input
    self.icon = icon
    self.label_id = label_id
    self.label_text = label_text
  end

  def view_template
    div do
      input(class: "form-control", type: "text", **input_attrs)
      i(class: "fa #{icon} field-icon")
      label(id: label_id, class: "field-label", for: input_attrs[:id]) do
        label_text
      end
    end
  end
end
