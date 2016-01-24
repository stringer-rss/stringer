require "nokogiri"
require "uri"

module UrlHelpers
  ABS_RE = URI::DEFAULT_PARSER.regexp[:ABS_URI]

  def expand_absolute_urls(content, base_url)
    doc = Nokogiri::HTML.fragment(content)

    [%w(a href), %w(img src), %w(video src)].each do |tag, attr|
      doc.css("#{tag}[#{attr}]").each do |node|
        url = node.get_attribute(attr)
        next if url =~ ABS_RE

        begin
          node.set_attribute(attr, URI.join(base_url, url).to_s)
        rescue URI::InvalidURIError # rubocop:disable Lint/HandleExceptions
          # Just ignore. If we cannot parse the url, we don't want the entire
          # import to blow up.
        end
      end
    end

    doc.to_html
  end

  def normalize_url(url, base_url)
    uri = URI.parse(url)

    # resolve (protocol) relative URIs
    if uri.relative?
      base_uri = URI.parse(base_url)
      scheme = base_uri.scheme || "http"
      uri = URI.join("#{scheme}://#{base_uri.host}", uri)
    end

    uri.to_s
  end
end
