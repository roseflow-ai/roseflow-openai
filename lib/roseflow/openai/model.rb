# frozen_string_literal: true

require "dry-struct"
require "roseflow/tokenizer"
require "active_support/core_ext/module/delegation"

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
        @tokenizer_ ||= Tokenizer.new(model: name)
      end

      # Handles the model call.
      # FIXME: Operations should be rewritten to match the client API.
      #
      # @param operation [Symbol] Operation to perform
      # @param input [String] Input to use
      def call(operation, input, **options)
        token_count = tokenizer.count_tokens(transform_chat_messages(input))
        if token_count < max_tokens
          case operation
          when :chat
            @provider_.create_chat_completion(model: name, messages: transform_chat_messages(input), **options)
          when :completion
            @provider_.create_completion(input)
          when :image
            @provider_.create_image_completion(input)
          when :embed
            @provider_.create_embedding(input)
          else
            raise ArgumentError, "Invalid operation: #{operation}"
          end
        else
          raise TokenLimitExceededError, "Token limit for model #{name} exceeded: #{token_count} is more than #{max_tokens}"
        end
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

      def assign_attributes
        @name = @model_.fetch("id")
        @created_at = Time.at(@model_.fetch("created"))
        @permissions_ = @model_.fetch("permission").first
      end

      def transform_chat_messages(input)
        input.map(&:to_h)
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
      attribute :permission, Types::Array.of(ModelPermission)
      attribute :root, Types::String
      attribute :parent, Types::String | Types::Nil

      alias_method :name, :id

      def permissions
        permission.first
      end

      delegate :finetuneable?, :is_blocking?, to: :permissions
    end # ModelConfiguration
  end # OpenAI
end # Roseflow
