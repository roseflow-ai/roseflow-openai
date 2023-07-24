# frozen_string_literal: true

require_relative "base"

module Roseflow
  module OpenAI
    module Operations
      # Embedding operation.
      #
      # Get a vector representation of a given input that can be easily
      # consumed by machine learning models and algorithms.
      #
      # See https://platform.openai.com/docs/api-reference/embeddings
      # for more information.
      #
      # Many of the attributes are actually optional for the API, but we
      # provide defaults to them. This may change in the future.
      class Embedding < Base
        attribute :input, Types::OpenAI::StringOrArray
        attribute? :user, Types::String

        attribute :path, Types::String.default("/v1/embeddings")
      end
    end
  end
end
