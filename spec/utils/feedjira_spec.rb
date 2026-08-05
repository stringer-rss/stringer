# frozen_string_literal: true

# Guards config/initializers/sax_machine.rb. These assert parser behaviour
# rather than the patch itself, so they still fail if a sax-machine upgrade
# stops the prepend from applying.
RSpec.describe Feedjira do
  def secret_file
    Tempfile.new("xxe").tap do |file|
      file.write("TOP-SECRET-CONTENTS")
      file.close
    end
  end

  def parse_feed(doctype, title)
    described_class.parse(<<~XML)
      <?xml version="1.0"?>
      #{doctype}
      <rss version="2.0"><channel>
        <title>#{title}</title>
        <link>http://example.com</link>
      </channel></rss>
    XML
  end

  it "does not resolve external entities pointing at local files" do
    secret = secret_file
    doctype = %(<!DOCTYPE rss [<!ENTITY xxe SYSTEM "file://#{secret.path}">]>)

    expect(parse_feed(doctype, "&xxe;").title.to_s)
      .not_to include("TOP-SECRET-CONTENTS")
  end

  it "still resolves predefined and numeric entities" do
    expect(parse_feed("", "Tom &amp; Jerry caf&#233;").title)
      .to eq("Tom & Jerry café")
  end

  it "still resolves entities declared inside the document" do
    doctype = %(<!DOCTYPE rss [<!ENTITY nbsp "&#160;">]>)

    expect(parse_feed(doctype, "Feed&nbsp;Title").title)
      .to eq("Feed\u00A0Title")
  end
end
