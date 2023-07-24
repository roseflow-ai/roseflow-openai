require "spec_helper"

module Roseflow
  module OpenAI
    module Operations
      RSpec.describe Completion do
        let(:default_options) do
          {
            model: "gpt-3.5-turbo",
            prompt: "Correct spelling mistakes: \n\n1. I can't wait to se",
          }
        end

        let(:default) { described_class.new(default_options) }

        it { expect(default).to be_a(described_class) }
        it { expect { default }.not_to raise_error }

        it "has the correct path" do
          expect(default.path).to eq("/v1/completions")
        end
      end
    end
  end
end
