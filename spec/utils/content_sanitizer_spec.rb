# frozen_string_literal: true

RSpec.describe ContentSanitizer do
  it "handles <wbr> tag properly" do
    result = described_class.call("<code>WM_<wbr\t\n >ERROR</code> asdf")

    expect(result).to eq("<code>WM_ERROR</code> asdf")
  end

  it "handles <figure> tag properly" do
    result = described_class.call("<figure>some code</figure>")

    expect(result).to eq("<figure>some code</figure>")
  end

  it "handles unprintable characters" do
    result = described_class.call("n\u2028\u2029")

    expect(result).to eq("n")
  end

  it "preserves line endings" do
    result = described_class.call("test\r\ncase")

    expect(result).to eq("test\r\ncase")
  end
end
