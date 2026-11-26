# frozen_string_literal: true

class Components::SetupField < Components::Base
  attr_accessor :form, :field, :label, :type

  def initialize(form:, field:, label:, type: :text)
    super()
    self.form = form
    self.field = field
    self.label = label
    self.type = type
  end

  def view_template
    div do
      if type == :password
        form.password_field(field, class: "form-control", required: true)
        i(class: "fa fa-lock field-icon")
      else
        form.text_field(field, class: "form-control", required: true)
      end
      form.label(field, label, class: "field-label")
    end
  end
end
