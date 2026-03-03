# frozen_string_literal: true

RSpec.describe "tutorial" do
  def visit_tutorial
    expect(CallableJob).to receive(:perform_later)
    visit(setup_tutorial_path)
  end

  it "displays the tutorial page" do
    login_as(default_user)

    visit_tutorial

    expect(page).to have_content("Stringer is simple")
  end

  it "displays sample stories" do
    login_as(default_user)

    visit_tutorial

    expect(page).to have_content("Darin' Fireballs")
  end
end
