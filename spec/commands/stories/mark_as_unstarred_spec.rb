require "spec_helper"

app_require "commands/stories/mark_as_unstarred"

describe MarkAsUnstarred do
  describe "#mark_as_unstarred" do
    let(:story) { double }
    let(:repo) { double(fetch: story) }

    it "marks a story as unstarred" do
      command = MarkAsUnstarred.new(1, repo)
      expect(story).to receive(:update_attributes).with(is_starred: false)
      command.mark_as_unstarred
    end
  end
end
