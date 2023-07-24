# frozen_string_literal: true

RSpec.describe ApplicationRecord do
  describe ".boolean_accessor" do
    with_model :Cheese, superclass: described_class do
      table { |t| t.jsonb(:options, default: {}) }
    end

    describe "#<key>" do
      it "returns the value when present" do
        Cheese.boolean_accessor(:options, :stinky)
        cheese = Cheese.new(options: { stinky: true })

        expect(cheese.stinky).to be(true)
      end

      it "returns false by default" do
        Cheese.boolean_accessor(:options, :stinky)
        cheese = Cheese.new

        expect(cheese.stinky).to be(false)
      end

      it "returns the default when value is nil" do
        Cheese.boolean_accessor(:options, :stinky, default: true)
        cheese = Cheese.new

        expect(cheese.stinky).to be(true)
      end

      it "casts the value to a boolean" do
        Cheese.boolean_accessor(:options, :stinky)
        cheese = Cheese.new(options: { stinky: "true" })

        expect(cheese.stinky).to be(true)
      end
    end

    describe "#<key>=" do
      it "sets the value" do
        Cheese.boolean_accessor(:options, :stinky)
        cheese = Cheese.new

        cheese.stinky = true

        expect(cheese.options).to eq({ "stinky" => true })
      end

      it "casts the value to a boolean" do
        Cheese.boolean_accessor(:options, :stinky)
        cheese = Cheese.new

        cheese.stinky = "true"

        expect(cheese.options).to eq({ "stinky" => true })
      end

      it "uses the default when value is nil" do
        Cheese.boolean_accessor(:options, :stinky, default: true)
        cheese = Cheese.new

        cheese.stinky = nil

        expect(cheese.options).to eq({ "stinky" => true })
      end
    end
  end
end
