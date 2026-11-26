# frozen_string_literal: true

class Views::Accounts::Remove < Views::Base
  include Phlex::Rails::Helpers::ButtonTo

  attr_accessor :user

  def initialize(user:)
    super()
    self.user = user
  end

  def page_title = t("page_titles.delete_account")

  def view_template
    h1 { t("accounts.remove.title") }

    p { t("accounts.remove.warning", username: user.username) }

    div(class: "actions") do
      delete_button
      a(href: account_path) { t("accounts.remove.cancel") }
    end
  end

  private

  def delete_button
    button_to(
      t("accounts.remove.confirm"),
      account_path,
      method: :delete,
      class: "btn btn-danger"
    )
  end
end
