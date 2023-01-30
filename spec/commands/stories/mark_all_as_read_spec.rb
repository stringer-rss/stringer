# frozen_string_literal: true

require "spec_helper"

describe MarkAllAsRead do
  describe "#call" do
    let(:stories) { double }
    let(:repo) { double(fetch_by_ids: stories) }

    it "marks all stories as read" do
      expect(stories).to receive(:update_all).with(is_read: true)

      described_class.call([1, 2], repo)
    end
  end
end
