# frozen_string_literal: true

require "rubocop"
require "rubocop-rspec"
require "rubocop/rspec/cop_helper"
require "rubocop/rspec/expect_offense"
require_relative("../../../../../linters/rubocop/cop/rspec/no_before_hook")

RSpec.describe RuboCop::Cop::RSpec::NoBeforeHook do
  include CopHelper
  include RuboCop::RSpec::ExpectOffense

  let(:cop) { described_class.new }

  it "registers an offense for a before block" do
    expect_offense(<<~RUBY)
      before { do_something }
      ^^^^^^^^^^^^^^^^^^^^^^^ RSpec/NoBeforeHook: Do not use `before` hooks.
    RUBY
  end

  it "registers an offense for before(:each)" do
    expect_offense(<<~RUBY)
      before(:each) { do_something }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/NoBeforeHook: Do not use `before` hooks.
    RUBY
  end

  it "registers an offense for before(:all)" do
    expect_offense(<<~RUBY)
      before(:all) { do_something }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/NoBeforeHook: Do not use `before` hooks.
    RUBY
  end

  it "does not register an offense for an after block" do
    expect_no_offenses(<<~RUBY)
      after { do_something }
    RUBY
  end

  it "does not register an offense for a regular method call" do
    expect_no_offenses(<<~RUBY)
      def setup
        do_something
      end
    RUBY
  end
end
