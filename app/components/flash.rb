# frozen_string_literal: true

class Components::Flash < Components::Base
  include Phlex::Rails::Helpers::Flash

  def view_template
    if flash.key?(:success)
      div(class: "alert alert-success success") { flash[:success] }
    end
    if flash.key?(:error)
      div(class: "alert alert-danger error") { flash[:error] }
    end

    noscript do
      div(class: "alert alert-danger error") { t("flash.js_required") }
    end
  end
end
