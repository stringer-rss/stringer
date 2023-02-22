# frozen_string_literal: true

module Downloads
  TIMEOUT = Capybara.default_max_wait_time
  PATH    = Rails.root.join("tmp/downloads")

  class << self
    def clear
      FileUtils.rm_f(downloads)
    end

    def content_for(filename)
      wait_for_download(filename)

      File.read(PATH.join(filename))
    end

    private

    def downloads
      Dir[PATH.join("*")]
    end

    def wait_for_download(filename)
      Timeout.timeout(TIMEOUT) { sleep(0.1) until downloaded?(filename) }
    end

    def downloaded?(filename)
      File.exist?(PATH.join(filename))
    end
  end
end

RSpec.configure do |config|
  config.after(:each, type: :system) { Downloads.clear }
end
