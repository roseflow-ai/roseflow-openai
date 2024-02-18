# frozen_string_literal: true

require "spec_helper"
require "json"
require "roseflow/openai/model"

module Roseflow
  module OpenAI
    RSpec.describe ModelConfiguration do
      let(:configuration) { JSON.parse(::File.read("spec/fixtures/models/gpt-3_5-turbo.json")) }

      subject { ModelConfiguration.new(configuration) }

      it "can be instantiated with valid model configuration" do
        expect(subject).to be_a described_class
      end

      it "has a name" do
        expect(subject.name).to eq "gpt-3.5-turbo"
      end

      it "has a defined permission set" do
        expect(subject.permission).to all(be_a ModelPermission)
      end
    end
  end
end