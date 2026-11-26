# frozen_string_literal: true

class Views::Debug::Heroku < Views::Base
  SCHEDULER_TASK = <<~TEXT
    Task: rake lazy_fetch
    Dyno Size: 1X
    Frequency: Hourly
  TEXT

  def view_template
    instructions
    start_button
  end

  private

  def instructions
    div(class: "setup", id: "heroku-setup") do
      h1 { t("tutorial.heroku_one_more_thing") }
      p { t("tutorial.heroku_hourly_task") }
      p { "#{t('tutorial.heroku_scheduler')}:" }
      pre { SCHEDULER_TASK }
    end
  end

  def start_button
    div(class: "center") do
      a(href: "/", id: "start", class: "btn btn-primary") do
        t("tutorial.ready")
      end
    end
  end
end
