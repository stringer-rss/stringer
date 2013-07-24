require "highline"
require "open-uri"
require_relative "../commands/stories/import_from_google_reader_stars"

class ImportGoogleReaderStars
  def initialize(path, ui = HighLine.new)
    @path = path
    @ui   = ui
  end

  def import_google_reader_stars
    json_str = ""

    if @path.nil?
      @ui.say "You need to provide a file path or URL."
      return
    end

    if File.exists? @path
      json_str = IO.read @path
    else
      # Try as URL
      begin
        open(@path) do |f|
          json_str = f.read
        end
      rescue
        @ui.say "The specified path couldn't be found or failed to load."
        return
      end
    end

    ImportFromGoogleReaderStars.import json_str
  end
end
