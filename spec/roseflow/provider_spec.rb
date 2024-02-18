# frozen_string_literal: true

require "spec_helper"
require "roseflow/openai/config"
require "roseflow/openai/provider"
require "roseflow/openai/embedding"

Anyway::Settings.use_local_files = true
provider_config = Roseflow::OpenAI::Config.new

VCR.configure do |config|
  config.filter_sensitive_data("<OPENAI_KEY>") { provider_config.api_key }
  config.filter_sensitive_data("<OPENAI_ORGANIZATION_ID>") { provider_config.organization_id }
end

def gpt_3_5(provider)
  Roseflow::OpenAI::Model.new(
    JSON.parse(::File.read("spec/fixtures/models/gpt-3_5-turbo.json")),
    provider
  )
end

def gpt_3_5_instruct(provider)
  Roseflow::OpenAI::Model.new(
    JSON.parse(::File.read("spec/fixtures/models/gpt-3_5-turbo-instruct.json")),
    provider
  )
end

def davinci_003(provider)
  Roseflow::OpenAI::Model.new(
    JSON.parse(::File.read("spec/fixtures/models/text-davinci-003.json")),
    provider
  )
end

def davinci_edit_001(provider)
  Roseflow::OpenAI::Model.new(
    JSON.parse(::File.read("spec/fixtures/models/text-davinci-edit-001.json")),
    provider
  )
end

def embedding_ada(provider)
  Roseflow::OpenAI::Model.new(
    JSON.parse(::File.read("spec/fixtures/models/text-embedding-ada-002.json")),
    provider
  )
end

module Roseflow
  module OpenAI
    RSpec.describe Provider do
      let(:provider) { described_class.new }

      describe "Models" do
        it "returns a list of models" do
          VCR.use_cassette("openai/models", record: :new_episodes) do
            expect(provider.models).to be_a Roseflow::OpenAI::ModelRepository

            provider.models.each do |model|
              expect(model).to be_a OpenAI::Model
            end
          end
        end
      end

      describe "API methods" do
        describe "Chat completion" do
          describe "Default" do
            let(:model) do
              data = JSON.parse(::File.read("spec/fixtures/models/gpt-3_5-turbo.json"))
              Roseflow::OpenAI::Model.new(data, provider)
            end

            it "returns a response" do
              VCR.use_cassette("openai/chat/default", record: :new_episodes) do
                messages = [
                  { role: "user", content: "Hello!" },
                  { role: "assistant", content: "Hi there! How can I assist you today?" },
                  { role: "user", content: "Tell me a funny joke" },
                ]

                response = provider.chat(model: model, messages: messages)
                expect(response).to be_a OpenAI::ChatResponse
                expect(response.response.to_s).to be_a String
              end
            end
          end

          describe "Streaming" do
            let(:model) do
              data = JSON.parse(::File.read("spec/fixtures/models/gpt-3_5-turbo.json"))
              Roseflow::OpenAI::Model.new(data, provider)
            end

            it "returns a streaming response" do
              VCR.use_cassette("openai/chat/streaming", record: :new_episodes) do
                messages = [
                  { role: "user", content: "Hello!" },
                  { role: "assistant", content: "Hi there! How can I assist you today?" },
                  { role: "user", content: "Tell me a funny joke" },
                ]

                response = provider.chat(model: model, messages: messages, streaming: true) do |response|
                  expect(response).to be_a String
                end
              end
            end
          end
        end

        describe "Completion" do
          describe "Default" do
            let(:model) { gpt_3_5_instruct(provider) }

            it "returns a response" do
              VCR.use_cassette("openai/completion/default", record: :new_episodes) do
                response = provider.completion(model: model, prompt: "Describe Ruby modules", max_tokens: 64)
                expect(response).to be_a OpenAI::CompletionResponse
                expect(response.response.to_s).to be_a String
              end
            end
          end

          describe "Streaming" do
            let(:model) { gpt_3_5_instruct(provider) }

            it "streams the response" do
              VCR.use_cassette("openai/completion/streaming", record: :new_episodes) do
                response = provider.completion(model: model, prompt: "Describe Ruby modules", max_tokens: 64, streaming: true) do |response|
                  expect(response).to be_a String
                end
                expect(response).to be_a Array
                expect(response).to all(be_a String)
              end
            end
          end
        end

        describe "Image" do
        end

        describe "Embedding" do
          let(:model) { embedding_ada(provider) }

          it "returns an embedding" do
            VCR.use_cassette("openai/embedding", record: :new_episodes) do
              response = provider.embedding(model: model, input: "Once upon a time")
              expect(response).to be_a Embeddings::Embedding
            end
          end
        end
      end
    end # Provider
  end # OpenAI
end # Roseflow
