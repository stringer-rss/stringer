# frozen_string_literal: true

class Views::Debug::Index < Views::Base
  attr_accessor :queued_jobs_count, :pending_migrations, :user_agent

  def initialize(queued_jobs_count:, pending_migrations:, user_agent:)
    super()
    self.queued_jobs_count = queued_jobs_count
    self.pending_migrations = pending_migrations
    self.user_agent = user_agent
  end

  def page_title = t("page_titles.debug")

  def view_template
    div(id: "debug") do
      h1 { "Debug Information" }
      dl do
        item("Ruby Version") { RUBY_VERSION }
        item("User Agent") { user_agent }
        item("Queued Jobs") { queued_jobs_count.to_s }
        item("Pending Migrations") { migrations }
      end
    end
  end

  private

  def item(term, &)
    dt { term }
    dd(&)
  end

  def migrations
    if pending_migrations.present?
      ul { pending_migrations.each { |migration| li { migration } } }
    else
      plain("None")
    end
  end
end
