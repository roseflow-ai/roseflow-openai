require "spec_helper"

module Roseflow
  module OpenAI
    module Operations
      RSpec.describe Chat do
        let(:default_options) do
          {
            model: "gpt-3.5-turbo",
            messages: [{ role: "system", content: "You are a helpful assistant." }],
          }
        end

        let(:default) { described_class.new(default_options) }

        it { expect(default).to be_a(described_class) }
        it { expect { default }.not_to raise_error }

        it "has the correct path" do
          expect(default.path).to eq("/v1/chat/completions")
        end
      end
    end
  end
end
