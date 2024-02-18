# frozen_string_literal: true

require "dry-struct"
require "roseflow/tiktoken/tokenizer"
require "active_support"
require "active_support/core_ext/module/delegation"

require "roseflow/openai/operation_handler"
require "roseflow/openai/model_configuration"
require "roseflow/openai/model_permission"
require "roseflow/openai/chat_message"
require "roseflow/openai/chat_message_builder"

module Types
  include Dry.Types()
end

module Roseflow
  module OpenAI
    class Model
      MAX_TOKENS_DEFAULT = 2049

      attr_reader :name

      # Initializes a new model instance.
      #
      # @param model [Hash] Model data from the API
      # @param provider [Roseflow::OpenAI::Provider] Provider instance
      def initialize(model, provider)
        @model_ = model
        @provider_ = provider
        assign_attributes
      end

      # Tokenizer instance for the model.
      def tokenizer
        @tokenizer_ ||= Roseflow::Tiktoken::Tokenizer.new(model: name)
      end

      # Convenience method for chat completions.
      #
      # @param messages [Array<ChatMessage>] Messages to use
      # @param options [Hash] Options to use
      # @yield [chunk] Chunk of data if stream is enabled
      # @return [OpenAI::ChatResponse] the chat response object if no block is given
      def chat(messages, options = {}, &block)
        messages = ensure_chat_messages(messages)
        token_count = tokenizer.count_tokens(transform_chat_messages(options.fetch(:messages, [])))
        raise TokenLimitExceededError, "Token limit for model #{name} exceeded: #{token_count} is more than #{max_tokens}" if token_count > max_tokens
        operation_opts = options.merge({ messages: messages, model: name })
        response = call(:chat, operation_opts, &block)

        unless block_given?
          return ErrorResponse.new(response) if response.status == 400
          return ChatResponse.new(response)
        end
      end

      # Calls the model.
      #
      # @param operation [Symbol] Operation to perform
      # @param options [Hash] Options to use
      # @yield [chunk] Chunk of data if stream is enabled
      # @return [Faraday::Response] raw API response if no block is given
      def call(operation, options, &block)
        operation = OperationHandler.new(operation, options).call
        client.post(operation, &block)
      end

      def embed(options)
        response = call(:embedding, options.merge({ model: name }))
        EmbeddingApiResponse.new(response)
      end

      # Returns a list of operations for the model.
      #
      # TODO: OpenAI does not actually provide this information per model.
      # Figure out a way to do this in a proper way if feasible.
      def operations
        OperationHandler::OPERATION_CLASSES.keys
      end

      # Indicates if the model is chattable.
      def chattable?
        OpenAI::Config::CHAT_MODELS.include?(name)
      end

      # Indicates if the model can do completions.
      def completionable?
        OpenAI::Config::COMPLETION_MODELS.include?(name)
      end

      # Indicates if the model can do image completions.
      def imageable?
        OpenAI::Config::IMAGE_MODELS.include?(name)
      end

      # Indicates if the model can do embeddings.
      def embeddable?
        OpenAI::Config::EMBEDDING_MODELS.include?(name)
      end

      # Indicates if the model is fine-tunable.
      def finetuneable?
        @permissions_.fetch("allow_fine_tuning")
      end

      # Indicates if the model has searchable indices.
      def searchable_indices?
        @permissions_.fetch("allow_search_indices")
      end

      # Indicates if the model can be sampled.
      def sampleable?
        @permissions_.fetch("allow_sampling")
      end

      def blocking?
        @permissions_.fetch("is_blocking")
      end

      # Returns the maximum number of tokens for the model.
      def max_tokens
        OpenAI::Config::MAX_TOKENS.fetch(name, MAX_TOKENS_DEFAULT)
      end

      private

      attr_reader :provider_

      def assign_attributes
        @name = @model_.fetch("id")
        @created_at = Time.at(@model_.fetch("created"))
        # @permissions_ = @model_.fetch("permission").first
      end

      def transform_chat_messages(input)
        input.map(&:to_h)
      end

      def client
        provider_
      end

      def ensure_chat_messages(messages)
        return messages if messages.all? { |message| message.is_a?(Roseflow::Chat::Message) }
        ChatMessageBuilder.new(messages).call
      end
    end # Model

    # Represents a model configuration.
  end # OpenAI
end # Roseflow
