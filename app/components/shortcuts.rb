# frozen_string_literal: true

# The keyboard shortcuts dialog, opened from the footer.
class Components::Shortcuts < Components::Base
  def view_template
    div(id: "shortcuts", class: "modal fade", tabindex: "-1", role: "dialog") do
      div(class: "modal-dialog") do
        div(class: "modal-content") do
          modal_header
          div(class: "modal-body") { ul(class: "shortcut-legend") { keys } }
        end
      end
    end
  end

  private

  def modal_header
    div(class: "modal-header") do
      h4(id: "myModalLabel") { t("partials.shortcuts.title") }
      button(
        type: "button",
        class: "btn-close",
        data: { bs_dismiss: "modal" },
        aria_label: "Close"
      )
    end
  end

  def keys
    story_keys
    li(class: "blank")
    action_keys
    li(class: "blank")
    shortcut(["←"], t("partials.shortcuts.keys.left"))
    shortcut(["→"], t("partials.shortcuts.keys.right"))
  end

  def story_keys
    shortcut(["j", "k"], t("partials.shortcuts.keys.jk"), "/")
    shortcut(["n", "p"], t("partials.shortcuts.keys.np"), "/")
    shortcut(["o", "enter"], t("partials.shortcuts.keys.oenter"), or_text)
    shortcut(["m"], t("partials.shortcuts.keys.m"))
    shortcut(["s"], t("partials.shortcuts.keys.s"))
    shortcut(["b", "v"], t("partials.shortcuts.keys.bv"), or_text)
  end

  def action_keys
    shortcut(["a"], t("partials.shortcuts.keys.a"))
    shortcut(["shift", "a"], t("partials.shortcuts.keys.shifta"), "+")
    shortcut(["f"], t("partials.shortcuts.keys.f"))
    shortcut(["r"], t("partials.shortcuts.keys.r"))
  end

  # Renders e.g. `<kbd>o</kbd> or <kbd>enter</kbd>: open/close`.
  def shortcut(keys, description, separator = nil)
    li do
      keys.each_with_index do |key, index|
        plain(separator) if index.positive?
        kbd { key }
      end
      plain(": #{description}")
    end
  end

  def or_text
    " #{t('partials.shortcuts.keys.or')} "
  end
end
