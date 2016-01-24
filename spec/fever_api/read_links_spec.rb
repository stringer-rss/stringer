require "spec_helper"

app_require "fever_api/read_links"

describe FeverAPI::ReadLinks do
  subject { FeverAPI::ReadLinks.new }

  it "returns a fixed link list if requested" do
    expect(subject.call("links" => nil)).to eq(links: [])
  end

  it "returns an empty hash otherwise" do
    expect(subject.call).to eq({})
  end
end
