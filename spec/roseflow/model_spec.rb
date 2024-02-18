# frozen_string_literal: true

require "spec_helper"

def gpt_3_5(provider)
  Roseflow::OpenAI::Model.new(
    JSON.parse(::File.read("spec/fixtures/models/gpt-3_5-turbo.json")),
    provider
  )
end

module Roseflow
  module OpenAI
    RSpec.describe Model do
      let(:provider) { Roseflow::OpenAI::Provider.new }
      let(:model) { gpt_3_5(provider) }

      describe "#initialize" do
        it "initializes a model" do
          expect(model).to be_a(described_class)
        end
      end

      describe "#operations" do
        it "returns a list of operations" do
          expect(model.operations).to be_a(Array)
          expect(model.operations).to include(:chat)
        end
      end

      describe "#chat" do
        it "can be called" do
          expect(model).to respond_to(:chat)
        end

        let(:messages) do
          [
            { role: "system", content: "You are a helpful assistant." },
            { role: "user", content: "Count from one to five." },
          ]
        end

        it "returns a chat response" do
          VCR.use_cassette("openai/model/chat", record: :new_episodes) do
            response = model.chat(messages)
            expect(response).to be_a(Roseflow::OpenAI::ChatResponse)
            expect(response.response).to be_a(Roseflow::OpenAI::Choice)
          end
        end
      end

      describe "#call" do
        it "can be called" do
          expect(model).to respond_to(:call)
        end

        context "with a valid operation" do
          let(:opts) do
            {
              model: model.name,
              messages: [
                { role: "system", content: "You are a helpful assistant." },
                { role: "user", content: "Hello, I'm John." },
              ],
            }
          end

          it "can be called with a valid operation" do
            VCR.use_cassette("openai/model/call", record: :new_episodes) do
              result = model.call(:chat, opts)
              expect(result).to be_a(Faraday::Response)
            end
          end

          it "can be called with a valid operation and a block" do
            VCR.use_cassette("openai/model/call_stream", record: :new_episodes) do
              result = model.call(:chat, opts.merge(stream: true)) do |chunk|
                expect(chunk).to be_a(String)
              end
            end
          end
        end

        context "with an invalid operation" do
          it "raises an error when called with an invalid operation" do
            expect { model.call(:invalid, { prompt: "Hello, world!" }) }.to raise_error(ArgumentError, "Invalid operation: invalid")
          end
        end
      end
    end
  end
end
