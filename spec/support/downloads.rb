# frozen_string_literal: true

module Downloads
  PATH = Rails.root.join("tmp/downloads")

  class << self
    def clear
      FileUtils.rm_f(downloads)
    end

    def content_for(page, filename)
      page.document.synchronize(errors: [Errno::ENOENT]) do
        File.read(PATH.join(filename))
      end
    end

    private

    def downloads
      Dir[PATH.join("*")]
    end
  end
end

RSpec.configure do |config|
  config.after(:each, type: :system) { Downloads.clear }
end
