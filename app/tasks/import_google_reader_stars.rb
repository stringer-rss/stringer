require "highline"
require "open-uri"
require_relative "../commands/stories/import_from_google_reader_stars"

class ImportGoogleReaderStars
  def initialize(path, ui = HighLine.new)
    @path = path
    @ui   = ui
  end

  def import_google_reader_stars
    if @path.nil?
      @ui.say "You need to provide a file path or URL."
      return
    end

    json_str = fetch_json @path

    if json_str.nil?
      @ui.say "The specified path couldn't be found or failed to load."
      return
    end

    ImportFromGoogleReaderStars.import json_str
  end

  private

  def fetch_json(path_or_url)
    if File.exists? path_or_url
      return IO.read path_or_url
    else
      # Try as URL
      begin
        open(path_or_url) do |f|
          return f.read
        end
      rescue
        return nil
      end
    end
  end
end
