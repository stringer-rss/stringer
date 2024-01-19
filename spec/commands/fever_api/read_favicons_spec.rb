# frozen_string_literal: true

RSpec.describe FeverAPI::ReadFavicons do
  it "returns a fixed icon list if requested" do
    expect(described_class.call({ favicons: nil })).to eq(
      favicons: [
        {
          id: 0,
          data: "image/gif;base64,#{described_class::ICON}"
        }
      ]
    )
  end

  it "returns an empty hash otherwise" do
    expect(described_class.call({})).to eq({})
  end
end
