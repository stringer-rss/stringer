# frozen_string_literal: true

RSpec.describe SafeFetch do
  describe ".guard" do
    it "yields the block result for http urls" do
      expect(described_class.guard("http://example.com") { :ok }).to eq(:ok)
    end

    it "yields the block result for https urls" do
      expect(described_class.guard("https://example.com") { :ok }).to eq(:ok)
    end

    it "raises UnsafeUrl for the file scheme" do
      expect { described_class.guard("file:///etc/passwd") { :ok } }
        .to raise_error(SafeFetch::UnsafeUrl)
    end

    it "raises UnsafeUrl for a scheme-less url" do
      expect { described_class.guard("example.com") { :ok } }
        .to raise_error(SafeFetch::UnsafeUrl)
    end

    it "raises UnsafeUrl for a malformed url" do
      expect { described_class.guard("http://[bad") { :ok } }
        .to raise_error(SafeFetch::UnsafeUrl)
    end
  end

  describe ".body" do
    it "fetches the url body through the guard" do
      response = instance_double(HTTParty::Response, to_s: "<rss/>")
      expect(HTTParty)
        .to receive(:get).with("http://example.com").and_return(response)

      expect(described_class.body("http://example.com")).to eq("<rss/>")
    end

    it "raises UnsafeUrl without fetching for non-http(s) schemes" do
      expect { described_class.body("file:///etc/passwd") }
        .to raise_error(SafeFetch::UnsafeUrl)
    end
  end
end
