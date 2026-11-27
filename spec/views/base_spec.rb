# frozen_string_literal: true

RSpec.describe Views::Base do
  it "requires subclasses to define a page title" do
    view = Class.new(described_class).new

    expect { view.page_title }.to raise_error(NotImplementedError)
  end
end
