# frozen_string_literal: true

require_relative "base"

require "roseflow/types"
require "roseflow/openai/chat_message"
require "ulid"

module Roseflow
  module OpenAI
    module Operations
      # Chat operation.
      #
      # Given a list of messages comprising a conversation, the model will
      # return a response.
      #
      # See https://platform.openai.com/docs/api-reference/chat for more
      # information.
      #
      # Many of the attributes are actually optional for the API, but we
      # provide defaults to them. This may change in the future.
      class Chat < Base
        attribute :messages, Types::Array.of(ChatMessage)
        attribute? :functions, Types::Array.of(Types::Hash)
        attribute? :function_call, Types::OpenAI::StringOrObject
        attribute :temperature, Types::Float.default(1.0)
        attribute :top_p, Types::Float.default(1.0)
        attribute :n, Types::Integer.default(1)
        attribute :stream, Types::Bool.default(false)
        attribute? :stop, Types::OpenAI::StringOrArray
        attribute? :max_tokens, Types::Integer
        attribute :presence_penalty, Types::Number.default(0)
        attribute :frequency_penalty, Types::Number.default(0)
        attribute? :user, Types::String

        attribute :instrumentation, Types::Bool.default(false)
        attribute :stream_events, Types::Bool.default(false)
        attribute :stream_id, Types::StringOrNil.default(ULID.generate)
        attribute :path, Types::String.default("/v1/chat/completions")

        def excluded_keys
          [:path, :instrumentation, :stream_events, :stream_id]
        end
      end
    end
  end
end
