# frozen_string_literal: true

require "dry-struct"
require "roseflow/tiktoken/tokenizer"
require "active_support/core_ext/module/delegation"

require "roseflow/openai/operation_handler"

module Types
  include Dry.Types()
end

module Roseflow
  module OpenAI
    class Model
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
      # @param messages [Array<String>] Messages to use
      # @param options [Hash] Options to use
      # @yield [chunk] Chunk of data if stream is enabled
      # @return [OpenAI::ChatResponse] the chat response object if no block is given
      def chat(messages, options = {}, &block)
        token_count = tokenizer.count_tokens(transform_chat_messages(options.fetch(:messages, [])))
        raise TokenLimitExceededError, "Token limit for model #{name} exceeded: #{token_count} is more than #{max_tokens}" if token_count > max_tokens
        response = call(:chat, options.merge({ messages: messages, model: name }), &block)
        ChatResponse.new(response) unless block_given?
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
        OpenAI::Config::MAX_TOKENS.fetch(name, 2049)
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
    end # Model

    # Represents a model permission.
    class ModelPermission < Dry::Struct
      transform_keys(&:to_sym)

      attribute :id, Types::String
      attribute :object, Types::String
      attribute :created, Types::Integer
      attribute :allow_create_engine, Types::Bool
      attribute :allow_sampling, Types::Bool
      attribute :allow_logprobs, Types::Bool
      attribute :allow_search_indices, Types::Bool
      attribute :allow_view, Types::Bool
      attribute :allow_fine_tuning, Types::Bool
      attribute :organization, Types::String
      attribute :is_blocking, Types::Bool

      alias_method :finetuneable?, :allow_fine_tuning
      alias_method :is_blocking?, :is_blocking
    end # ModelPermission

    # Represents a model configuration.
    class ModelConfiguration < Dry::Struct
      transform_keys(&:to_sym)

      attribute :id, Types::String
      attribute :created, Types::Integer
      attribute? :permission, Types::Array.of(ModelPermission)
      attribute? :root, Types::String
      attribute? :parent, Types::String | Types::Nil

      alias_method :name, :id

      def permissions
        permission.first
      end

      delegate :finetuneable?, :is_blocking?, to: :permissions
    end # ModelConfiguration
  end # OpenAI
end # Roseflow
