class ContentSanitizer
  def self.sanitize(content)
    Loofah.fragment(content.gsub(/<wbr\s*>/i, ""))
          .scrub!(:prune)
          .scrub!(:unprintable)
          .to_s
  end
end
