require_relative "./add_new_feed"

class ImportFromText
  def self.import(file_name)
    text = File.open(file_name).read
    text.gsub!(/\r\n?/, "\n")

    text.each_line do |line|
      AddNewFeed.add(line)
    end
  end
end
