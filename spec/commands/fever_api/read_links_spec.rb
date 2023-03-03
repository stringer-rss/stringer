# frozen_string_literal: true

RSpec.describe FeverAPI::ReadLinks do
  it "returns a fixed link list if requested" do
    expect(described_class.call(links: nil)).to eq(links: [])
  end

  it "returns an empty hash otherwise" do
    expect(described_class.call({})).to eq({})
  end
end
