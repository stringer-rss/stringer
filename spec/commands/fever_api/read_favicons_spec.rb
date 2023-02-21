# frozen_string_literal: true

describe FeverAPI::ReadFavicons do
  subject { described_class }

  it "returns a fixed icon list if requested" do
    expect(subject.call("favicons" => nil)).to eq(
      favicons: [
        {
          id: 0,
          data: "image/gif;base64,#{described_class::ICON}"
        }
      ]
    )
  end

  it "returns an empty hash otherwise" do
    expect(subject.call({})).to eq({})
  end
end
