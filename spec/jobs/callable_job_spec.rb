# frozen_string_literal: true

RSpec.describe CallableJob do
  it "calls the callable" do
    callable = ->(*, **) {}

    expect { described_class.perform_now(callable, "foo", bar: "baz") }
      .to invoke(:call).on(callable).with("foo", bar: "baz")
  end
end
