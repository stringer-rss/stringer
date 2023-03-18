# frozen_string_literal: true

RSpec.describe FeverAPI::Authentication do
  def authorization
    Authorization.new(default_user)
  end

  it "returns the latest feed's last_fetched time" do
    feed = create(:feed, last_fetched: 1.month.ago)
    create(:feed, last_fetched: 1.year.ago)

    result = described_class.call(authorization:)
    expect(result[:last_refreshed_on_time]).to eq(Integer(feed.last_fetched))
  end

  it "returns 0 for last_refreshed_on_time when there are no feeds" do
    result = described_class.call(authorization:)
    expect(result[:last_refreshed_on_time]).to eq(0)
  end

  it "returns a hash with keys :auth and :last_refreshed_on_time" do
    result = described_class.call(authorization:)
    expect(result).to eq(auth: 1, last_refreshed_on_time: 0)
  end
end
