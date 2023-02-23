# frozen_string_literal: true

RSpec.describe Authorization do
  describe "#check" do
    it "raises an error if the record belongs to another user" do
      user = create(:user)
      feed = create(:feed)

      expect { described_class.new(user).check(feed) }
        .to raise_error(Authorization::NotAuthorizedError)
    end

    describe "when the user owns the record" do
      it "marks the request as authorized" do
        feed = create(:feed)
        authorization = described_class.new(feed.user)

        authorization.check(feed)

        expect(authorization).to be_authorized
      end

      it "returns the record" do
        feed = create(:feed)
        authorization = described_class.new(feed.user)

        expect(authorization.check(feed)).to eq(feed)
      end
    end
  end

  describe "#scope" do
    it "returns the records that belong to the user" do
      feed = create(:feed)

      expect(described_class.new(feed.user).scope(Feed)).to eq([feed])
    end

    it "does not return records that belong to another user" do
      create(:feed, user: create(:user))

      expect(described_class.new(default_user).scope(Feed)).to be_empty
    end

    it "marks the request as authorized" do
      authorization = described_class.new(default_user)

      authorization.scope(Feed)

      expect(authorization).to be_authorized
    end
  end

  describe "#skip" do
    it "marks the request as authorized" do
      authorization = described_class.new(default_user)

      authorization.skip

      expect(authorization).to be_authorized
    end
  end

  describe "#verify" do
    it "raises an error if the request was not authorized" do
      authorization = described_class.new(default_user)

      expect { authorization.verify }
        .to raise_error(Authorization::NotAuthorizedError)
    end

    it "does not raise an error if the request was authorized" do
      authorization = described_class.new(default_user)
      authorization.skip

      expect { authorization.verify }.not_to raise_error
    end
  end
end
