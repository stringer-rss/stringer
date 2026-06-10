# frozen_string_literal: true

# Guards outbound feed requests against SSRF (CWE-918). Refuses non-http(s)
# schemes and connections to private/reserved IPs, re-checking the connected
# address on every redirect hop via PrivateAddressCheck's socket patch.
module SafeFetch
  module_function

  ALLOWED_SCHEMES = ["http", "https"].freeze

  class UnsafeUrl < StandardError
  end

  # Fetch a URL body under SSRF protection.
  def body(url)
    guard(url) { HTTParty.get(url).to_s }
  end

  # Run a block (e.g. Feedbag discovery) under the same protections.
  def guard(url, &)
    raise(UnsafeUrl, url) if ALLOWED_SCHEMES.exclude?(scheme(url))

    PrivateAddressCheck.only_public_connections(&)
  end

  def scheme(url)
    URI.parse(url).scheme
  rescue URI::InvalidURIError
    nil
  end
end
