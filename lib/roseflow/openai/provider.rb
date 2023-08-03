# frozen_string_literal: true

require "roseflow/openai/client"
require "roseflow/openai/model_repository"

module Roseflow
  module OpenAI
    class Provider
      delegate :post, to: :client

      def initialize(config = Roseflow::OpenAI::Config.new)
        @config = config
      end

      # Returns the client for the provider
      def client
        @client ||= Client.new(config, self)
      end

      # Returns the model repository for the provider
      def models
        @models ||= ModelRepository.new(self)
      end

      # Chat with a model
      #
      # @param model [Roseflow::OpenAI::Model] The model object to use
      # @param messages [Array<String>] The messages to send to the model
      # @param options [Hash] Additional options to pass to the API
      # @option options [Integer] :max_tokens The maximum number of tokens to generate in the completion.
      # @option options [Float] :temperature Sampling temperature to use, between 0 and 2
      # @option options [Float] :top_p The cumulative probability of tokens to use.
      # @option options [Integer] :n The number of completions to generate.
      # @option options [Integer] :logprobs Include the log probabilities on the logprobs most likely tokens.
      # @option options [Boolean] :echo Whether to echo the question as part of the completion.
      # @option options [String | Array] :stop Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
      # @option options [Float] :presence_penalty Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
      # @option options [Float] :frequency_penalty Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
      # @option options [Integer] :best_of Generates `best_of` completions server-side and returns the "best" (the one with the lowest log probability per token)
      # @option options [Integer] :streaming Whether to stream back partial progress
      # @option options [String] :user A unique identifier representing your end-user
      # @return [Roseflow::OpenAI::ChatResponse] The response object from the API.
      def chat(model:, messages:, **options, &block)
        streaming = options.fetch(:streaming, false)

        if streaming
          client.streaming_chat_completion(model: model, messages: messages.map(&:to_h), **options, &block)
        else
          client.create_chat_completion(model: model, messages: messages.map(&:to_h), **options)
        end
      end

      # Create a completion.
      #
      # @param model [Roseflow::OpenAI::Model] The model object to use
      # @param prompt [String] The prompt to use for completion
      # @param options [Hash] Additional options to pass to the API
      # @option options [Integer] :max_tokens The maximum number of tokens to generate in the completion.
      # @option options [Float] :temperature Sampling temperature to use, between 0 and 2
      # @option options [Float] :top_p The cumulative probability of tokens to use.
      # @option options [Integer] :n The number of completions to generate.
      # @option options [Integer] :logprobs Include the log probabilities on the logprobs most likely tokens.
      # @option options [Boolean] :echo Whether to echo the question as part of the completion.
      # @option options [String | Array] :stop Up to 4 sequences where the API will stop generating further tokens.
      # @option options [Float] :presence_penalty Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
      # @option options [Float] :frequency_penalty Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
      # @option options [Integer] :best_of Generates `best_of` completions server-side and returns the "best" (the one with the lowest log probability per token)
      # @option options [Integer] :streaming Whether to stream back partial progress
      # @option options [String] :user A unique identifier representing your end-user
      # @return [Roseflow::OpenAI::CompletionResponse] The response object from the API.
      def completion(model:, prompt:, **options)
        streaming = options.fetch(:streaming, false)

        if streaming
          client.streaming_completion(model: model, prompt: prompt, **options)
        else
          client.create_completion(model: model, prompt: prompt, **options)
        end
      end

      # Creates a new edit for the provided input, instruction, and parameters.
      #
      # @param model [Roseflow::OpenAI::Model] The model object to use
      # @param instruction [String] The instruction to use for editing
      # @param options [Hash] Additional options to pass to the API
      # @option options [String] :input The input text to use as a starting point for the edit.
      # @option options [Integer] :n The number of edits to generate.
      # @option options [Float] :temperature Sampling temperature to use, between 0 and 2
      # @option options [Float] :top_p The cumulative probability of tokens to use.
      # @return [Roseflow::OpenAI::EditResponse] The response object from the API.
      def edit(model:, instruction:, **options)
        client.create_edit(model: model, instruction: instruction, **options)
      end

      # Creates an embedding vector representing the input text.
      #
      # @param model [Roseflow::OpenAI::Model] The model object to use
      # @param input [String] The input text to use for embedding
      # @param options [Hash] Additional options to pass to the API
      # @option options [String] :user A unique identifier representing your end-user
      def embedding(model:, input:, **options)
        client.create_embedding(model: model, input: input, **options).embedding.to_embedding
      end

      def image(prompt:, **options)
        client.create_image(prompt: prompt, **options)
      end

      attr_reader :config
    end # Provider
  end # OpenAI
end # Roseflow
