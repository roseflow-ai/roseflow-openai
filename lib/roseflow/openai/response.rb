# frozen_string_literal: true

require "dry-struct"
require "roseflow/types"
require "roseflow/openai/embedding"

module Roseflow
  module OpenAI
    FailedToCreateEmbeddingError = Class.new(StandardError)

    class ApiResponse
      def initialize(response)
        @response = response
      end

      def success?
        @response.success?
      end

      def status
        @response.status
      end

      def body
        raise NotImplementedError, "Subclasses must implement this method."
      end
    end # ApiResponse

    class TextApiResponse < ApiResponse
      def body
        @body ||= ApiResponseBody.new(JSON.parse(@response.body))
      end

      def usage
        body.usage
      end

      def choices
        body.choices.map { |choice| Choice.new(choice) }
      end
    end # TextApiResponse

    class ChatResponse < TextApiResponse
      def response
        choices.first
      end

      def to_s
        if choices.any?
          choices.first.to_s
        end
      end
    end

    class CompletionResponse < TextApiResponse
      def response
        choices.first
      end

      def responses
        choices
      end
    end

    class EditResponse < TextApiResponse
      def response
        choices.first
      end

      def responses
        choices
      end
    end

    class ImageApiResponse < ApiResponse
      def body
        @body ||= ImageApiResponseBody.new(JSON.parse(@response.body))
      end

      def images
        body.data.map { |image| Image.new(image) }
      end
    end # ImageApiResponse

    class EmbeddingApiResponse < ApiResponse
      def body
        @body ||= begin
            case @response.status
            when 200
              EmbeddingApiResponseBody.new(JSON.parse(@response.body))
            else
              EmbeddingApiResponseErrorBody.new(JSON.parse(@response.body))
            end
          end
      end

      def embedding
        case @response.status
        when 200
          body.data.map { |embedding| Embedding.new(embedding) }.first
        else
          raise FailedToCreateEmbeddingError, body.error.message
        end
      end
    end # EmbeddingApiResponse

    class Image < Dry::Struct
      transform_keys(&:to_sym)

      attribute :url, Types::String
    end # Image

    class Choice < Dry::Struct
      transform_keys(&:to_sym)

      attribute? :text, Types::String
      attribute? :message do
        attribute :role, Types::String
        attribute :content, Types::String
      end

      attribute? :finish_reason, Types::String
      attribute :index, Types::Integer

      def to_s
        return message.content if message
        return text if text
      end
    end # Choice

    class ApiUsage < Dry::Struct
      transform_keys(&:to_sym)

      attribute :prompt_tokens, Types::Integer
      attribute? :completion_tokens, Types::Integer
      attribute :total_tokens, Types::Integer
    end # ApiUsage

    class ImageApiResponseBody < Dry::Struct
      transform_keys(&:to_sym)

      attribute :created, Types::Integer
      attribute :data, Types::Array(Types::Hash)
    end # ImageApiResponseBody

    class OpenAIEmbedding < Dry::Struct
      transform_keys(&:to_sym)

      attribute :object, Types::String.default("embedding")
      attribute :embedding, Types::Array(::Types::Number)
      attribute :index, Types::Integer
    end # OpenAIEmbedding

    class EmbeddingApiResponseBody < Dry::Struct
      transform_keys(&:to_sym)

      attribute :object, Types::String
      attribute :data, Types::Array(OpenAIEmbedding)
      attribute :model, Types::String
      attribute :usage, ApiUsage
    end # EmbeddingApiResponseBody

    class EmbeddingApiResponseErrorBody < Dry::Struct
      transform_keys(&:to_sym)

      attribute :error do
        attribute :message, Types::String
      end
    end # EmbeddingApiResponseErrorBody

    class ApiResponseBody < Dry::Struct
      transform_keys(&:to_sym)

      attribute? :id, Types::String
      attribute :object, Types::String
      attribute :created, Types::Integer
      attribute? :model, Types::String
      attribute :usage, ApiUsage
      attribute :choices, Types::Array

      def success?
        true
      end
    end # ApiResponseBody
  end # OpenAI
end # Roseflow
