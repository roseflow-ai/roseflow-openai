# frozen_string_literal: true

require "roseflow/types"
require "roseflow/chat/message"

module Roseflow
  module OpenAI
    class ChatMessage < Roseflow::Chat::Message
      attribute? :function_call, Types::OpenAI::FunctionCallObject
    end

    class VisionChatMessage < ChatMessage
      attribute :content, Types::Array.of(Types::OpenAI::VisionChatMessageContent | Types::OpenAI::VisionImageMessageContent)
    end

    class VisionImageMessage < ChatMessage
      attribute :content, Types::OpenAI::VisionImageMessageContent
    end
  end
end
