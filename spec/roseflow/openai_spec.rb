# frozen_string_literal: true

require "spec_helper"

provider_config = Roseflow::OpenAI::Config.new

VCR.configure do |config|
  config.filter_sensitive_data("<OPENAI_KEY>") { provider_config.api_key }
  config.filter_sensitive_data("<OPENAI_ORGANIZATION_ID>") { provider_config.organization_id }
end

module Roseflow
  module OpenAI do
    let(:provider) { described_class.new() }

    describe "#models" do
      it "returns a list of models" do
        VCR.use_cassette("openai/models", record: :all) do
          expect(provider.models).to be_a Roseflow::Models::OpenAI::Repository

          provider.models.each do |model|
            expect(model).to be_a Models::OpenAI::Model
          end
        end
      end
    end

    describe "API methods" do
      let(:provider) { described_class.new() }

      describe "#create_chat_completion" do
        let(:model) do
          data = JSON.parse(File.read("./spec/fixtures/models/gpt-3_5-turbo.json"))
          Roseflow::Models::OpenAI::Model.new(data, provider)
        end

        it "returns a response" do
          VCR.use_cassette("openai", record: :all) do
            messages = [
              { role: "user", content: "Hello!"},
              { role: "assistant", content: "Hi there! How can I assist you today?" },
              { role: "user", content: "Tell me a funny joke"},
            ]
            response = provider.create_chat_completion(model: model.name, messages: messages)
            expect(response).to be_a Roseflow::Providers::OpenAI::TextApiResponse
            expect(response).to be_success
          end
        end
      end

      describe "#create_completion" do
        let(:model) do
          data = JSON.parse(File.read("./spec/fixtures/models/text-davinci-003.json"))
          Roseflow::Models::OpenAI::Model.new(data, provider)
        end

        it "returns a response" do
          VCR.use_cassette("openai", record: :new_episodes) do
            prompt = "Roseflow is a Ruby gem for using OpenAI's API. How do I integrate it into my application?"

            response = provider.create_completion(model: model.name, prompt: prompt)
            expect(response).to be_a Roseflow::Providers::OpenAI::TextApiResponse
            expect(response).to be_success
          end
        end
      end

      describe "#create_edit" do
        let(:model) do
          data = JSON.parse(File.read("./spec/fixtures/models/text-davinci-edit-001.json"))
          Roseflow::Models::OpenAI::Model.new(data, provider)
        end

        it "returns a response" do
          VCR.use_cassette("openai", record: :new_episodes) do
            instruction = "Fix the spelling mistakes"
            input = "Roseflow is a Ruuby gemm for useing OpenAI's API."

            response = provider.create_edit(model: model.name, instruction: instruction, input: input)
            expect(response).to be_a Roseflow::Providers::OpenAI::TextApiResponse
            expect(response).to be_success
          end
        end
      end

      describe "#create_image" do
        it "returns a response" do
          VCR.use_cassette("openai", record: :new_episodes) do
            prompt = "A cute baby sea otter"
            number_of_results = 2
            size = "1024x1024"

            response = provider.create_image(prompt: prompt, n: number_of_results, size: size)
            expect(response).to be_a Roseflow::Providers::OpenAI::ImageApiResponse
            expect(response).to be_success
          end
        end
      end

      describe "#create_embedding" do
        let(:model) do
          data = JSON.parse(File.read("./spec/fixtures/models/text-embedding-ada-002.json"))
          Roseflow::Models::OpenAI::Model.new(data, provider)
        end

        context "a single input" do
          it "returns a response" do
            VCR.use_cassette("openai", record: :new_episodes) do
              input = "Roseflow is a Ruby gem for using OpenAI's API."
              response = provider.create_embedding(model: model.name, input: input)
              expect(response).to be_a Roseflow::Providers::OpenAI::EmbeddingApiResponse
              expect(response).to be_success
            end
          end            
        end
      end
    end
  end
end