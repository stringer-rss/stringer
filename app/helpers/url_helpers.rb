# frozen_string_literal: true

module UrlHelpers
  def expand_absolute_urls(content, base_url)
    doc = Nokogiri::HTML.fragment(content)

    [["a", "href"], ["img", "src"], ["video", "src"]].each do |tag, attr|
      doc.css("#{tag}[#{attr}]").each do |node|
        url = Addressable::URI.parse(node.get_attribute(attr))
        next if url.absolute?

        # normalize percent-encodes any non-ascii (IRI) characters so the
        # resolved link is a valid URL.
        node[attr] = Addressable::URI.join(base_url, url).normalize.to_s
      rescue Addressable::URI::InvalidURIError
        # Just ignore. If we cannot parse the url, we don't want the entire
        # import to blow up.
      end
    end

    doc.to_html
  end

  ALLOWED_URL_SCHEMES = ["http", "https"].freeze

  def normalize_url(url, base_url)
    uri = Addressable::URI.parse(url.strip)

    # resolve (protocol) relative URIs
    if uri.relative?
      base_uri = Addressable::URI.parse(base_url.strip)
      scheme = base_uri.scheme || "http"
      uri = Addressable::URI.parse("#{scheme}://#{base_uri.host}").join(uri)
    end

    return if ALLOWED_URL_SCHEMES.exclude?(uri.scheme.downcase)

    # Percent-encode any non-ASCII characters (e.g. an IRI path) so the result
    # is a valid URL. normalize is idempotent, so already-encoded URLs are
    # left untouched rather than double-encoded.
    uri.normalize.to_s
  end

  def safe_normalize_url(url, base_url)
    return if url.blank?

    normalize_url(url, base_url)
  rescue Addressable::URI::InvalidURIError
    nil
  end
end
