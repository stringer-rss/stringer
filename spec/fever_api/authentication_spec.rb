# frozen_string_literal: true

require "spec_helper"

app_require "fever_api/authentication"

describe FeverAPI::Authentication do
  it "returns the latest feed's last_fetched time" do
    feed = create(:feed, last_fetched: 1.month.ago)
    create(:feed, last_fetched: 1.year.ago)

    result = described_class.new.call({})
    expect(result[:last_refreshed_on_time]).to eq(Integer(feed.last_fetched))
  end

  it "returns 0 for last_refreshed_on_time when there are no feeds" do
    result = described_class.new.call({})
    expect(result[:last_refreshed_on_time]).to eq(0)
  end

  it "returns a hash with keys :auth and :last_refreshed_on_time" do
    fake_clock = double("clock")
    result = described_class.new(clock: fake_clock).call(double)
    expect(result).to eq(auth: 1, last_refreshed_on_time: 0)
  end
end
