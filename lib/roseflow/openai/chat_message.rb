# frozen_string_literal: true

require "roseflow/chat/message"

module Types
  module OpenAI
    FunctionCallObject = Types::Hash
    StringOrObject = Types::String | FunctionCallObject
    StringOrArray = Types::String | Types::Array
  end
end

module Roseflow
  module OpenAI
    class ChatMessage < Roseflow::Chat::Message
      attribute? :function_call, Types::OpenAI::FunctionCallObject
    end
  end
end
