require "spec_helper"

app_require "fever_api/authentication"

describe FeverAPI::Authentication do
  it "returns a hash with keys :auth and :last_refreshed_on_time" do
    fake_clock = double("clock")
    expect(fake_clock).to receive(:now).and_return(1234567890)
    result = FeverAPI::Authentication.new(clock: fake_clock).call(double)
    expect(result).to eq(auth: 1, last_refreshed_on_time: 1234567890)
  end
end
