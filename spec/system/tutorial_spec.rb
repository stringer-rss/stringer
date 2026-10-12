# frozen_string_literal: true

RSpec.describe "tutorial" do
  around { |example| with_test_adapter(&example) }

  it "displays the tutorial page" do
    login_as(default_user)

    visit(setup_tutorial_path)

    expect(page).to have_text("Stringer is simple")
    expect(CallableJob).to have_been_enqueued
  end

  it "displays sample stories" do
    login_as(default_user)

    visit(setup_tutorial_path)

    expect(page).to have_text("Darin' Fireballs")
  end
end
