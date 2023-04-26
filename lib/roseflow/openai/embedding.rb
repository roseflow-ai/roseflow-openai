# frozen_string_literal: true

require "roseflow/types"
require "roseflow/embeddings/embedding"

module Roseflow
  module OpenAI
    class Embedding < Dry::Struct
      transform_keys(&:to_sym)

      attribute :embedding, Types::Array.of(Types::Float)

      def to_embedding
        Roseflow::Embeddings::Embedding.new(vector: embedding, length: embedding.length)
      end
    end # Embedding
  end # OpenAI
end # Roseflow