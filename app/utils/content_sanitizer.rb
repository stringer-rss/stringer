# frozen_string_literal: true

module ContentSanitizer
  def self.call(content)
    Loofah.fragment(content.gsub(/<wbr\s*>/i, ""))
          .scrub!(:prune)
          .scrub!(:unprintable)
          .to_s
  end
end
