# frozen_string_literal: true

require_relative "base"

module Roseflow
  module OpenAI
    module Operations
      # Completion operation.
      #
      # Given a prompt, the model will return one or more predicted
      # completions, and can also return the probabilities of
      # alternative tokens at each position.
      #
      # See https://platform.openai.com/docs/api-reference/completions
      # for more information.
      #
      # Many of the attributes are actually optional for the API, but we
      # provide defaults to them. This may change in the future.
      class Completion < Base
        attribute :prompt, Types::OpenAI::StringOrArray
        attribute? :suffix, Types::String
        attribute :max_tokens, Types::Integer.default(16)
        attribute :temperature, Types::Float.default(1.0)
        attribute :top_p, Types::Float.default(1.0)
        attribute :n, Types::Integer.default(1)
        attribute :stream, Types::Bool.default(false)
        attribute? :logprobs, Types::Integer
        attribute :echo, Types::Bool.default(false)
        attribute? :stop, Types::OpenAI::StringOrArray
        attribute :presence_penalty, Types::Number.default(0)
        attribute :frequency_penalty, Types::Number.default(0)
        attribute :best_of, Types::Integer.default(1)
        attribute? :user, Types::String

        attribute :path, Types::String.default("/v1/completions")
      end
    end
  end
end
